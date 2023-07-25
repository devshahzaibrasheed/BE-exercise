# frozen_string_literal: true

require './app/app.rb'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*' 
    resource '*',  headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
  end
end

run App
