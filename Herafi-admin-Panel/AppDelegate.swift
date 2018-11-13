//
//  AppDelegate.swift
//  Herafi-admin-Panel
//
//  Created by Mohsen Qaysi on 11/13/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // init the window
        window = UIWindow()
        window?.rootViewController = MainTabBarController()
        
        attemtRegisteringForPushNotifications(application: application)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Token: \(deviceToken.debugDescription)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Registered with FCM with token: \(fcmToken)")
    }
    
    // listen for user notifications and present notification on the forground of the app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userinfo = response.notification.request.content.userInfo
        if let orderID = userinfo["orderId"] as? String {
            print("orderId: \(orderID)")
            print("order data from AppDeleagte")
            Database.fetchOrderData(orderId: orderID) { (order) in
                //MARK: - push data to the the order view controller
                let orderContoller = OrderController()
                orderContoller.order = order
                
                if let mainTabBarContoller = self.window?.rootViewController as? MainTabBarController {
                    mainTabBarContoller.selectedIndex = 0
//                    mainTabBarContoller.presentedViewController?.dismiss(animated: true, completion: nil)
                    if let homenavigationContoller = mainTabBarContoller.viewControllers?.first as? UINavigationController {
                        homenavigationContoller.popViewController(animated: true)
                        orderContoller.hidesBottomBarWhenPushed = true
                        homenavigationContoller.pushViewController(orderContoller, animated: true)
                    }
                }
            }
        }
    }
    
    private func attemtRegisteringForPushNotifications(application: UIApplication) {
        print("Attemting to register APNS...")
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
            if let err = err {
                print("Failed to request auth: ", err)
                return
            }
            
            if granted {
                print("Auth granted")
            } else {
                print("Auth denided")
            }
        }
        
        application.registerForRemoteNotifications()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}



