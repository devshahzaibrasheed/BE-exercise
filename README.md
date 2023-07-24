# Booking portal exercise

The "Booking portal" is an application with the purpose of
creating payment bookings. It consists on a payment form with the following structure:

![alt tag](https://user-images.githubusercontent.com/34654846/37901679-4a71cd5a-30f2-11e8-83f2-d18ec3f594aa.png)

When the form is submitted, the application creates a payment record with the provided information.

This application also has an API consisting of 2 endpoints that are detailed on the [Readme](server/README.md).

Please develop a **second application**, inside the ``client`` directory, that communicates with the "booking portal"(Server) application in order to accomplish the following:

It should implement an API endpoint /payments_with_quality_check which returns a JSON with the next structure:
``{
  bookings_with_quality_check: [
    {
      reference: (type: string),
      amount: (type: number),
      amountWithFees: (type: number),
      amountReceived: (type: number),
      qualityCheck: (type: string separated by commas),
      overPayment:  (type: boolean),
      underPayment:  (type: boolean)
    }
  ]
}``

## definition of values:

### amountWithFees:
* if the amount <= 1000 USD: 5% fees
* if the amount > 1000 USD AND <= 10000 USD: 3% fees
* if the amount > 10000 USD: 2% fees

### qualityCheck:
* **InvalidEmail**: If the payment has an invalid email add ``InvalidEmail`` string to the ``qualityCheck`` string.
* **DuplicatedPayment**: If the user that booked the payment has already a payment in the system add ``DuplicatedPayment`` string to the ``qualityCheck`` string.
* **AmountThreshold**: If the amount of the payment in USD including fees is bigger than 1.000.000$ add ``AmountThreshold`` string to the ``qualityCheck`` string.

### overPayment:
* An **over-payment** happens when the user pays more than the tuition amount in USD including fees we introduced in the booking portal.

### underPayment:
* An **under-payment** happens when the user pays less than the tuition amount in USD including fees we introduced in the booking portal.

*** All amounts referenced above are in USD but you can receive a different currency from the server which will need to be converted to create the extra values **

Here you can see an example on how this information could be displayed:

![alt tag](https://user-images.githubusercontent.com/34654846/37902217-fe20f97e-30f3-11e8-9594-fe4d611344b0.png)

### Notes

* The client code should be implemented in a BE programming language
* You should not use a FrontEnd library such as Angular/Vue/React or even pure JS for the client part (node.js is allowed). You may use FrontEnd libraries if you decided to add UI in addition to the BE part, but this is not mandatory.
* We don't expect changes to be made on the server application. It should be treated as an external application owned by someone else.
* You can implement the client application in the programming language of your preference.
* Tests are required.
* Nothing is bulletproof. Hence please don't assume things like - "this server will not have any error"

*** Important Note:  The client should be seen as the BE of a web system and the Server is the 3rd-party Payments API which we cannot modify as part the exercise. For your convenience we added a UI for the DB used by the server so you could add mock payments to the payment repository for testing purposes.
