//
//  IAP.swift
//  LiveUseful
//
//  Created by Megabits on 2018/2/4.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import StoreKit

protocol iapDelegate: class {
    func iapRefreshed()
    func iapPurchased()
    func TransactionsFinished(_ message: String?)
    func iapRestoreFailed(_ message: String?)
    func iapError()
}

class iap :NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    weak var delegate: iapDelegate?
    
    let proID = "com.JinyuMeng.liveuseful_pro"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var priceStrings = [String]()
    
    #if DEBUG
//    var isPro = UserDefaults.standard.bool(forKey: "isPro")
    var isPro = true
    #else
    var isPro = UserDefaults.standard.bool(forKey: "isPro") {
        didSet{
            UserDefaults.standard.set(isPro, forKey: "isPro")
        }
    }
    #endif
   
    func fetchAvailableProducts() {
        let productIdentifiers = NSSet(objects: proID)
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    //Get product data
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        priceStrings = [String]()
        if (response.products.count > 0) {
            iapProducts = response.products
            
            let firstProduct = response.products[0] as SKProduct
            
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            let price1Str = numberFormatter.string(from: firstProduct.price)
            
            priceStrings.append(price1Str!)
            delegate?.iapRefreshed()
        }
    }
    
    //Purchases
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
        } else {
            delegate?.iapError()
        }
    }
    
    //Purchases result
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if productID == proID {
                        isPro = true
                        delegate?.iapPurchased()
                    }
                    break
                case .failed:
                    delegate?.TransactionsFinished(trans.error?.localizedDescription)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    isPro = true
                    delegate?.iapPurchased()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                default: break
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    
    func restorePurchase() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.iapRestoreFailed(error.localizedDescription)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.TransactionsFinished(nil)
    }
}
