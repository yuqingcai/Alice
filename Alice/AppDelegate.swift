//
//  AppDelegate.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/7.
//

import UIKit
import StoreKit

let retailVersion = true

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var colorSchemeGenerator: ColorSchemeGenerator?
    var colorSampler: ColorSampler?
    var colorComposer: ColorComposer?
    var localLibrary: LocalLibrary?
    
    var receiptVerificationTimer: Timer?
    let receiptVerificationTimerInterval: Double = 30.0 //second
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActiveResponder), name: AppStore.subscriptionActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDeactiveResponder), name: AppStore.subscriptionDeactiveNotification, object: nil)
        
        ColorFunction.createWheelHues("Artist")
        localLibrary = LocalLibrary()
        colorSampler = ColorSampler()
        
        if let wheelHues = ColorFunction.wheelHues {
            colorComposer = ColorComposer(hues: wheelHues, defaultComposeType: .analogous)
        }
        
        if ((localLibrary?.openDatabase()) == nil)  {
            return false
        }
        
        SKPaymentQueue.default().add(AppStore.sharedInstance)
        
        Settings.sharedInstance.load()
        
        enableApplicationTimer()
        
        return true
    }
    
    func enableApplicationTimer() {
        receiptVerificationTimer = Timer.scheduledTimer(withTimeInterval: receiptVerificationTimerInterval, repeats: true, block: {
            timer in
            if AppStore.sharedInstance.verifyReceiptState != .finished {
                AppStore.sharedInstance.verifyReceipt()
            }
        })
        receiptVerificationTimer?.fire()
        RunLoop.current.add(receiptVerificationTimer!, forMode: RunLoop.Mode.common)
    }
        
    func disableApplicationTimer() {
        receiptVerificationTimer?.invalidate()
        receiptVerificationTimer = nil
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        disableApplicationTimer()
        SKPaymentQueue.default().remove(AppStore.sharedInstance)
        localLibrary?.closeDatabase()
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func unsubscribedRestrict(feature: String?) -> Bool {
        if (retailVersion == false) {
            return false
        }
        
        guard let localLibrary = localLibrary else {
            return false
        }
        
        if feature == nil {
            return Settings.sharedInstance.isSubscriptionActive == false
        }
        else if (feature?.compare("savetolibrary", options: .caseInsensitive) == .orderedSame ||
                feature?.compare("share", options: .caseInsensitive) == .orderedSame) {
            return Settings.sharedInstance.isSubscriptionActive == false && localLibrary.numberOfSnapshootOrderByModifiedDateAscending() >= 4
        }
        return false
    }
    
    @objc func subscriptionActiveResponder() {
        Settings.sharedInstance.isSubscriptionActive = true
    }
    
    @objc func subscriptionDeactiveResponder() {
        Settings.sharedInstance.isSubscriptionActive = false
    }
}


