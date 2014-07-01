# http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial
class IAPHelper
  attr_accessor :products_request, :completion_handler, :product_identifiers, :purchased_product_identifiers
  attr_accessor :cancelled, :success

  def initialize(product_identifiers)
    # Store product identifiers
    @product_identifiers = product_identifiers

    #Check for previously purchased products
    @purchased_product_identifiers = NSMutableSet.set
    @product_identifiers.each do |product_identifier|
      product_purchased = NSUserDefaults.standardUserDefaults.boolForKey(product_identifier)
      if product_purchased
        @purchased_product_identifiers.addObject(product_identifier)
        NSLog("Previously purchased: %@", product_identifier)
      else
        NSLog("Not purchased: %@", product_identifier)
      end
    end

    # Add self as transaction observer
    SKPaymentQueue.defaultQueue.addTransactionObserver(self)
  end

  def request_product_info(&block)
    NSLog('Requesting product information')
    @completion_handler = block

    @products_request = sk_products_request.alloc.initWithproduct_identifiers(@product_identifiers)
    @products_request.delegate = self
    @products_request.start
  end

  def product_purchased?(product_identifier)
    @purchased_product_identifiers.containsObject(product_identifier)
  end

  def buy_product(product)
    NSLog("Buying %@...", product.product_identifier)

    payment = SKPayment.paymentWithProduct(product)
    SKPaymentQueue.defaultQueue.addPayment(payment)
  end

  #pragma mark - sk_products_requestDelegate

  def products_request(request, didReceiveResponse:response)
    NSLog("Loaded list of products...")
    @products_request = nil

    sk_products = response.products
    sk_products.each do |sk_product|
      NSLog("Found product: %@ %@ %0.2", sk_product.product_identifier, sk_product.localizedTitle, sk_product.price.floatValue)
    end

    @completion_handler.call(true, sk_products)
    @completion_handler = nil
  end

  def request(request, didFailWithError:error)
    NSLog("Failed to load list of products.")
    @products_request = nil

    @completion_handler.call(false, nil)
    @completion_handler = nil
  end

#pragma mark SKPaymentTransactionObserver

  def paymentQueue(queue, updatedTransactions:transactions)
    transactions.each do |transaction|
      case transaction.transactionState
      when SKPaymentTransactionStatePurchased
        self.completeTransaction(transaction)
      when SKPaymentTransactionStateFailed
        self.failedTransaction(transaction)
      when SKPaymentTransactionStateRestored
        self.restoreTransaction(transaction)
      else
      end
    end
  end

  def completeTransaction(transaction)
    NSLog("completeTransaction...")

    self.provide_content(transaction.payment.product_identifier)
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
  end

  def restoreTransaction(transaction)
    NSLog("restoreTransaction...")

    self.provide_content(transaction.originalTransaction.payment.product_identifier)
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
  end

  def failedTransaction(transaction)
    NSLog("failedTransaction...")
    if transaction.error.code != SKErrorPaymentCancelled
      NSLog("Transaction error: %@", transaction.error.localizedDescription)
    else
      @cancelled.call unless @cancelled.nil?
    end
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
  end

  def provide_content(product_identifier)
    @purchased_product_identifiers.addObject(product_identifier)
    NSUserDefaults.standardUserDefaults.setBool(true, forKey:product_identifier)
    NSUserDefaults.standardUserDefaults.synchronize
    @success.call unless @success.nil?
  end

  def restoreCompletedTransactions
    SKPaymentQueue.defaultQueue.restoreCompletedTransactions
  end

end
