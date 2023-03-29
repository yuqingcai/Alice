//
//  AppStore.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/14.
//

import Foundation
import StoreKit

enum VerifyReceiptState {
    case prepare
    case processing
    case finished
    case failed
}

class AppStore: NSObject, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //
    // products notification
    //
    static let gotProductNotification: Notification.Name = Notification.Name("gotProductNotification")
    
    //
    //  receipt notification
    //
    static let verifyReceiptErrorNotification: Notification.Name = Notification.Name("verifyReceiptErrorNotification")
    static let verifyReceiptFinishedNotification: Notification.Name = Notification.Name("verifyReceiptFinishedNotification")
    
    //
    // purchase notification
    //
    static let purchaseSuccessfulNotification: Notification.Name = Notification.Name("purchaseSuccessfulNotification")
    static let purchasingNotification: Notification.Name = Notification.Name("purchasingNotification")
    static let purchaseFailedNotification: Notification.Name = Notification.Name("purchaseFailedNotification")
    static let purchaseRestoredNotification: Notification.Name = Notification.Name("purchaseRestoredNotification")
    
    //
    // subscription notification
    //
    static let subscriptionActiveNotification: Notification.Name = Notification.Name("subscriptionActiveNotification")
    static let subscriptionDeactiveNotification: Notification.Name = Notification.Name("subscriptionDeactiveNotification")
    
    static let sharedInstance = AppStore()
    
    //
    // https://developer.apple.com/documentation/appstorereceipts/status
    //
    private static let status21000 = "App Store receiptThe request to the App Store didn’t use the HTTP POST request method."
    private static let status21002 = "The data in the receipt-data property is malformed or the service experienced a temporary issue. Try again."
    private static let status21003 = "The system couldn’t authenticate the receipt."
    private static let status21004 = "The shared secret you provided doesn’t match the shared secret on file for your account."
    private static let status21005 = "The receipt server was temporarily unable to provide the receipt. Try again."
    private static let status21006 = "This receipt is valid, but the subscription is in an expired state. When your server receives this status code, the system also decodes and returns receipt data as part of the response. This status only returns for iOS 6-style transaction receipts for auto-renewable subscriptions."
    private static let status21007 = "This receipt is from the test environment, but you sent it to the production environment for verification."
    private static let status21008 = "This receipt is from the production environment, but you sent it to the test environment for verification."
    private static let status21009 = "Internal data access error. Try again later."
    private static let status21010 = "The system can’t find the user account or the user account has been deleted."
    private static let internalDataAccessErrors = "internal data access errors"
    
    // Receipt verify URLs
    let productionURLString = "https://buy.itunes.apple.com/verifyReceipt"
    let sandboxURLString = "https://sandbox.itunes.apple.com/verifyReceipt"

    // Shared Secret
    let primarysharedSecret = "c038bf5ca1c240668f6e48425e47ade0"
    let appSpecificSharedSecret = "86183ed07b0a48a69f896334a24eeab4"

    // Products
    let subscriptionMonthlyIdentifier = "io.coloury.subscription.monthly"
    let subscriptionYearlyIdentifier = "io.coloury.subscription.yearly"
    
    var products: Array<SKProduct>?
    var verifyReceiptState: VerifyReceiptState = .prepare
    
    private var isSubscriptionActived: Bool = false {
        didSet {
            if isSubscriptionActived == true {
                NotificationCenter.default.post(name: AppStore.subscriptionActiveNotification, object: self)
            }
            else {
                NotificationCenter.default.post(name: AppStore.subscriptionDeactiveNotification, object: self)
            }
        }
    }
    
    private func getDate(from GMTString: String) -> Date? {
        let format = DateFormatter()
        format.timeZone = TimeZone(identifier: "GMT")
        format.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        return format.date(from: GMTString)
    }
    
    func verifyReceipt() {
        print("Verifying receipt...")
        if NetworkReachability.isConnectedToNetwork() == false {
            print("Internet Connection not Available!")
            NotificationCenter.default.post(name: NetworkReachability.unreachableNotification, object: self, userInfo: nil)
            return
        }
        
        if (verifyReceiptState == .processing) {
            return
        }
        
        verifyReceiptState = .processing
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                verifyReceiptFromProduction(receiptData)
            }
            catch {
                verifyReceiptError(info: "Couldn't read receipt data: " + error.localizedDescription)
                verifyReceiptState = .failed
            }
        }
        else {
            let receiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            receiptRefreshRequest.delegate = self
            receiptRefreshRequest.start()
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                do {
                    let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                    verifyReceiptFromProduction(receiptData)
                }
                catch {
                    verifyReceiptError(info: "Couldn't read receipt data: " + error.localizedDescription)
                    verifyReceiptState = .failed
                }
            }
            else {
                verifyReceiptError(info: "Couldn't read receipt data: receipt dones't exist")
                verifyReceiptState = .failed
            }
        }
    }
    
    private func verifyReceiptFromProduction(_ receiptData: Data) {
        print("verify receipt from production")
        if let storeURL = URL(string: productionURLString) {
            verifyReceipt(receiptData:receiptData, storeURL: storeURL)
        }
    }
    
    private func verifyReceiptFromSandbox(_ receiptData: Data) {
        print("verify receipt from sandbox")
        if let storeURL = URL(string: sandboxURLString) {
            verifyReceipt(receiptData:receiptData, storeURL: storeURL)
        }
    }
        
    private func verifyReceipt(receiptData: Data, storeURL: URL) {
        let receiptString = receiptData.base64EncodedString(options: [])
        
        let contents = [
            "receipt-data": receiptString,
            "password": appSpecificSharedSecret,
        ]
        
        let httpBody = try? JSONSerialization.data(withJSONObject: contents)
        var request = URLRequest(url: storeURL)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, responds, error) in
            if let error = error {
                print("verify receipt error: \(error)")
                return
            }
            
            guard let data = data else {
                print("verify receipt error: no data")
                return
            }
            
            let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: AnyObject]
            if let status = jsonObject?["status"] as? Int32 {
                
                // no error, process subscription detecting
                if (status == 0) {
                    
                    // detect if there is a subscription and expired or not
                    if let latestReceiptInfo = jsonObject?["latest_receipt_info"] as? Array<Any> {
                        print(latestReceiptInfo)
                        
                        // Get the latest receipt index and expires_date_ms from
                        // latestReceiptInfo array.
                        // expires_date_ms is The time an auto-renewable subscription
                        // expires or when it will renew, in UNIX epoch time format,
                        // in milliseconds.
                        //
                        
                        var latestExpiresDateMS: Double? = nil
                        var latestIndex: Int? = nil
                        for i in 0 ..< latestReceiptInfo.count {
                            let receipt = latestReceiptInfo[i] as? [String: AnyObject]
                            
                            if let expiresDateMSString = receipt?["expires_date_ms"] as? String {
                                let timestamp = (expiresDateMSString as NSString).doubleValue
                                
                                if latestExpiresDateMS == nil {
                                    latestExpiresDateMS = timestamp
                                    latestIndex = i
                                }
                                else {
                                    if timestamp > latestExpiresDateMS! {
                                        latestExpiresDateMS = timestamp
                                        latestIndex = i
                                    }
                                }
                            }
                        }
                        
                        if let latestIndex = latestIndex {
                            let receipt = latestReceiptInfo[latestIndex] as? [String: AnyObject]
                            if let originalPurchaseDateMSString = receipt?["original_purchase_date_ms"] as? String {
                                let originalPurchaseDateMS = (originalPurchaseDateMSString as NSString).doubleValue
                                let originalPurchaseDate = Date(timeIntervalSince1970: TimeInterval(originalPurchaseDateMS/1000))
                                print("original purchase date: \(originalPurchaseDate)")
                            }
                        }
                        print("last subscription period: \(latestReceiptInfo.count)")
                        
                        // compare with expires_date_ms, latestExpiresDateMS is latest
                        // in latestReceiptInfo
                        if let latestExpiresDateMS = latestExpiresDateMS {
                            // convert latestExpiresDateMS in millisecond to seconds
                            let expiresDate = Date(timeIntervalSince1970: TimeInterval(latestExpiresDateMS/1000))
                            let currentDate = Date()
                                                        
                            if currentDate < expiresDate {
                                self.isSubscriptionActived = true
                            }
                            else {
                                self.isSubscriptionActived = false
                            }
                            
                            print("expires date: \(expiresDate), current date: \(currentDate), subscription actived: \(self.isSubscriptionActived)")
                        }
                        
                    }
                    else {
                        self.isSubscriptionActived = false
                        print("No latest_receipt_info found, the receipt doesn't contain any auto renew subscription")
                    }
                    
                    self.verifyReceiptFinished()
                }
                else if (status == 21000) {
                    self.verifyReceiptError(info: AppStore.status21000)
                    return
                }
                else if (status == 21002) {
                    self.verifyReceiptError(info: AppStore.status21002)
                    return
                }
                else if (status == 21003) {
                    self.verifyReceiptError(info: AppStore.status21003)
                    return
                }
                else if (status == 21004) {
                    self.verifyReceiptError(info: AppStore.status21004)
                    return
                }
                else if (status == 21005) {
                    self.verifyReceiptError(info: AppStore.status21005)
                    return
                }
                else if (status == 21006) {
                    self.verifyReceiptError(info: AppStore.status21006)
                    return
                }
                else if (status == 21007) {
                    self.verifyReceiptFromSandbox(receiptData)
                    return
                }
                else if (status == 21008) {
                    self.verifyReceiptFromProduction(receiptData)
                    return
                }
                else if (status == 21009) {
                    self.verifyReceiptError(info: AppStore.status21009)
                    return
                }
                else if (status == 21010) {
                    self.verifyReceiptError(info: AppStore.status21010)
                    return
                }
                else if (status >= 21100 && status <= 21199) {
                    self.verifyReceiptError(info: AppStore.internalDataAccessErrors)
                    return
                }
                
            }
        })
        task.resume()
    }
        
    private func verifyReceiptError(info: String) {
        print("verify receipt error:" + info)
        verifyReceiptState = .failed
        NotificationCenter.default.post(name: AppStore.verifyReceiptErrorNotification, object: self, userInfo: ["error": info])
    }
    
    private func verifyReceiptFinished() {
        print("verify receipt finished")
        verifyReceiptState = .finished
        NotificationCenter.default.post(name: AppStore.verifyReceiptFinishedNotification, object: self, userInfo: nil)
    }
    
    //
    // get products
    //
    func getProducts () {
        let request = SKProductsRequest(productIdentifiers: Set([
            subscriptionMonthlyIdentifier,
            subscriptionYearlyIdentifier
        ]))
        
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products;
        var info: [String: Any]? = nil
        if let products = products {
            for product in products {
                print("\(product.productIdentifier)")
                print("\(product.localizedTitle)")
                print("\(product.localizedDescription)")
                
                if let subscriptionPeriod = product.subscriptionPeriod {
                    switch(subscriptionPeriod.unit) {
                    case SKProduct.PeriodUnit.day:
                        print("day")
                    case SKProduct.PeriodUnit.week:
                        print("week")
                    case SKProduct.PeriodUnit.month:
                        print("month")
                    case SKProduct.PeriodUnit.year:
                        print("year")
                    @unknown default:
                        print("unknow")
                    }
                }
                print("\(product.price)")
                print("\(product.priceLocale)")
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                if let formattedString = numberFormatter.string(from: product.price) {
                    print(formattedString)
                }
            }
            
            info = ["products": products]
        }
        
        NotificationCenter.default.post(name: AppStore.gotProductNotification, object: self, userInfo: info)
    }
    
    //
    // payment
    //
    func payProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchasing:
                handleTranscactionPurchasing(transaction)
            case .purchased:
                handleTranscactionPurchased(transaction)
            case .failed:
                handleTranscactionFailed(transaction)
            case .restored:
                handleTranscactionRestored(transaction)
            case .deferred:
                handleTranscactionDeferred(transaction)
            @unknown default:
                break
            }
        }
    }
    
//    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
//        if (product.productIdentifier == subscriptionMonthlyIdentifier ||
//            product.productIdentifier == subscriptionYearlyIdentifier) {
//            return true
//        }
//        return false
//    }
    
    private func handleTranscactionPurchasing(_ transaction: SKPaymentTransaction) {
        NotificationCenter.default.post(name: AppStore.purchasingNotification, object: self)
    }
    
    private func handleTranscactionPurchased(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        isSubscriptionActived = true
        NotificationCenter.default.post(name: AppStore.purchaseSuccessfulNotification, object: self)
    }
    
    private func handleTranscactionFailed(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        NotificationCenter.default.post(name: AppStore.purchaseFailedNotification, object: self)
    }
    
    private func handleTranscactionRestored(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        NotificationCenter.default.post(name: AppStore.purchaseRestoredNotification, object: self)
    }
    
    private func handleTranscactionDeferred(_ transaction: SKPaymentTransaction) {
        print("deferred")
    }
}
