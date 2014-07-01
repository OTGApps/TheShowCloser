# http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial
class IAPHelper
  attr_accessor :productsRequest, :completionHandler, :productIdentifiers, :purchasedProductIdentifiers
  attr_accessor :cancelled, :success

  def initialize(productIdentifiers)
    # Store product identifiers
    @productIdentifiers = productIdentifiers

    #Check for previously purchased products
    @purchasedProductIdentifiers = NSMutableSet.set
    @productIdentifiers.each do |productIdentifier|
      productPurchased = NSUserDefaults.standardUserDefaults.boolForKey(productIdentifier)
      if productPurchased
        @purchasedProductIdentifiers.addObject(productIdentifier)
        NSLog("Previously purchased: %@", productIdentifier)
      else
        NSLog("Not purchased: %@", productIdentifier)
      end
    end

    # Add self as transaction observer
    SKPaymentQueue.defaultQueue.addTransactionObserver(self)
  end

  def requestProductInfo(&block)
    NSLog('Requesting product information')
    @completionHandler = block

    @productsRequest = SKProductsRequest.alloc.initWithProductIdentifiers(@productIdentifiers)
    @productsRequest.delegate = self
    @productsRequest.start
  end

  def productPurchased(productIdentifier)
    @purchasedProductIdentifiers.containsObject(productIdentifier)
  end

  def buyProduct(product)
    NSLog("Buying %@...", product.productIdentifier)

    payment = SKPayment.paymentWithProduct(product)
    SKPaymentQueue.defaultQueue.addPayment(payment)
  end

  #pragma mark - SKProductsRequestDelegate

  def productsRequest(request, didReceiveResponse:response)
    NSLog("Loaded list of products...")
    @productsRequest = nil

    skProducts = response.products
    skProducts.each do |skProduct|
      NSLog("Found product: %@ %@ %0.2", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue)
    end

    @completionHandler.call(true, skProducts)
    @completionHandler = nil
  end

  def request(request, didFailWithError:error)
    NSLog("Failed to load list of products.")
    @productsRequest = nil

    @completionHandler.call(false, nil)
    @completionHandler = nil
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

    self.provideContentForProductIdentifier(transaction.payment.productIdentifier)
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
  end

  def restoreTransaction(transaction)
    NSLog("restoreTransaction...")

    self.provideContentForProductIdentifier(transaction.originalTransaction.payment.productIdentifier)
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

  def provideContentForProductIdentifier(productIdentifier)
    @purchasedProductIdentifiers.addObject(productIdentifier)
    NSUserDefaults.standardUserDefaults.setBool(true, forKey:productIdentifier)
    NSUserDefaults.standardUserDefaults.synchronize
    #NSNotificationCenter.defaultCenter.postNotificationName('IAPHelperProductPurchasedNotification', object:productIdentifier, userInfo:nil)
    @success.call unless @success.nil?
  end

  def restoreCompletedTransactions
    SKPaymentQueue.defaultQueue.restoreCompletedTransactions
  end

end
