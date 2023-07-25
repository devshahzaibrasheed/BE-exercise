# frozen_string_literal: true

require 'bundler'
require 'dotenv'
Dotenv.load

Bundler.require(:default, ENV.fetch('RACK_ENV', 'development'))

class App < Sinatra::Base
  get '/bookings_with_quality_check' do
  	response = Faraday.get("#{ENV['SERVER_URL']}/api/bookings")
  	bookings = JSON.parse(response.body)['bookings']
  	bookings = bookings_with_quality_check(bookings)

    JSON.dump('bookings_with_quality_check' => bookings)
  end

  private

  def bookings_with_quality_check(bookings)
    result = []
    bookings.each do |booking|
      record = build_record(booking, result)
      result << record
    end
    
    result.map {|a| a.delete('student_id')}
    result
  end

  def build_record(booking, quality_check_bookings)
    record = {}
    record['reference'] = booking['reference']
    record['amount'] =  booking['amount'].nil? ? nil : amount(booking['currency_from'], booking['amount'])
    record['amount_with_fees'] = record['amount'].nil? ? nil : amount_with_fees(record['amount'])
    record['amount_received'] = booking['amount_received'].nil? ? nil : amount(booking['currency_from'], booking['amount_received'])
    record['quality_check'] = quality_check(booking, record['amount_with_fees'], quality_check_bookings)
    record['over_payment'] = over_payment(record)
    record['under_payment'] = under_payment(record)
    record['student_id'] = booking['student_id']

    record
  end

  def quality_check(booking, amount, quality_check_bookings)
    errors = []
    email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    email = booking['email']
    user = booking['student_id']
     
    errors << 'InvalidEmail' unless email.match?(email_regex)
    errors << "AmountThreshold" if amount.to_i > 1000000
    
    unless user.nil?
      duplicate_payments = quality_check_bookings.select {|a| a['student_id'] == user}
      if duplicate_payments.count > 0
        errors << "DuplicatedPayment"
      end
    end

    errors_string = errors.join(', ')
  end

  def over_payment(booking)
    return false if booking['amount'].nil?

    booking['amount_received'] > booking['amount_with_fees']
  end

  def under_payment(booking)
    return false if booking['amount'].nil?

    booking['amount_received'] < booking['amount_with_fees']
  end

  def amount(currency, amount)
    if currency.upcase == 'USD'
      amount
    elsif currency.upcase == 'EUR'
      (amount / currency_rate('USDEUR'))&.to_i
    elsif currency.upcase == 'CAD'
      (amount / currency_rate('USDCAD'))&.to_i
    end
  end

  def amount_with_fees(amount)
    if amount <= 1000
      (amount + (amount * 5/100))&.to_i
    elsif amount > 1000 && amount <= 10000
      (amount + (amount * 3/100))&.to_i
    elsif amount > 10000
      (amount + (amount * 2/100))&.to_i
    end
  end

  def currency_rate(currency)
    @rates ||= Faraday.get("http://apilayer.net/api/live?access_key=#{ENV['API_KEY']}&currencies=CAD,EUR&source=USD&format=1")
    JSON.parse(@rates.body)['quotes'][currency]
  end
end
