//
//  MobiFlowSwift.swift
//  MobFlow
//
//  Created by Smart Mobile Tech on 2/9/21.
//

import UIKit
import Adjust
import FirebaseCore
import FirebaseMessaging
import AppTrackingTransparency

public protocol MobiFlowDelegate
{
    func present(dic: [String: Any])
}

public class MobiFlowSwift: NSObject
{
    var isDeeplinkURL = 0
    var scheme = ""
    var endpoint = ""
    var adjAppToken = ""
    var adjPushToken = ""
    var customURL = ""
    var schemeURL = ""
    var addressURL = ""
    let gcmMessageIDKey = "gcm.Message_ID"
    public var delegate : MobiFlowDelegate? = nil
    var counter = 0
    var timer = Timer()
    public var backgroundColor = UIColor.white
    public var tintColor = UIColor.black
    public var hideToolbar = false

    public init(isDeeplinkURL: Int, scheme: String, endpoint: String, adjAppToken: String, adjPushToken: String)
    {
        super.init()
        
        self.isDeeplinkURL = isDeeplinkURL
        self.scheme = scheme
        self.endpoint = endpoint
        self.adjAppToken = adjAppToken
        self.adjPushToken = adjPushToken
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(appToken: self.adjAppToken, environment: environment)
        adjustConfig?.sendInBackground = true
        adjustConfig?.delegate = self
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        Adjust.addSessionCallbackParameter("App_To_Adjust_DeviceId", value: uuid)
        Adjust.appDidLaunch(adjustConfig)

        UIApplication.shared.registerForRemoteNotifications()
    }
    
    public func start()
    {
        if self.isDeeplinkURL == 0
        {
            self.startApp()
        }
        else if self.isDeeplinkURL == 1
        {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
        }
    }
    
    func requestPremission()
    {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        
        if #available(iOS 14, *)
        {
            ATTrackingManager.requestTrackingAuthorization { (authStatus) in
                switch authStatus
                {
                case .notDetermined:
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                case .denied:
                    print("Denied")
                case .authorized:
                    print("Authorized")
                @unknown default:
                    break
                }
            }
        }
    }
    
    @objc func updateCounting()
    {
        NSLog("counting..")
        if (UserDefaults.standard.value(forKey: "deeplinkURL") as? String) != nil
        {
            timer.invalidate()
            self.startApp()
        }
        else if counter < 10
        {
            counter = counter + 1
        }
        else
        {
            timer.invalidate()
            self.startApp()
        }
    }
    
    public func shouldShowPButton() -> Bool
    {
        if !self.addressURL.isEmpty
        {
            return true
        }
        return false
    }
    
    public func getSTitle() -> String
    {
        let urlToOpen = URL(string: self.addressURL.removingPercentEncoding!)
        if(urlToOpen?.query != nil)
        {
            if (urlToOpen?.queryDictionary!["sName"] != nil)
            {
                return (urlToOpen?.queryDictionary!["sName"] as? String)!
            }
        }

        return ""
    }
    
    func createCustomURL()
    {
        let lang = Locale.current.languageCode ?? ""
        let packageName = Bundle.main.bundleIdentifier ?? ""
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let adid = Adjust.adid() ?? ""
        let idfa = Adjust.idfa() ?? ""
        let fScheme = self.scheme.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        var d = ""
        if self.isDeeplinkURL == 1
        {
            if UserDefaults.standard.value(forKey: "deeplinkURL") != nil
            {
                let deeplinkURL = UserDefaults.standard.value(forKey: "deeplinkURL") as? String
                d = deeplinkURL!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                d = d.replacingOccurrences(of: "=", with: "%3D", options: .literal, range: nil)
                d = d.replacingOccurrences(of: "&", with: "%26", options: .literal, range: nil)
            }
        }
        let string =  "\(self.endpoint)?packageName=\(packageName)&flowName=iosBA&lang=\(lang)&deviceId=\(uuid)&adjustId=\(adid)&gpsAdid=\(idfa)&referringLink=\(d)&fScheme=\(fScheme)"
        self.customURL = string
    }
    
    func initWebViewURL() -> WebViewController
    {
        let urlToOpen = URL(string: self.customURL)
        let bundle = Bundle(for: type(of:self))
        let storyBoard = UIStoryboard(name: "Main", bundle:bundle)
        let webView = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webView.urlToOpen = urlToOpen!
        webView.schemeURL = self.schemeURL
        webView.addressURL = self.addressURL
        webView.delegate = self
        webView.tintColor = self.tintColor
        webView.backgroundColor = self.backgroundColor
        webView.hideToolbar = self.hideToolbar

        return webView
    }
    
    public func openWebView()
    {
        let urlToOpen = URL(string: self.addressURL.removingPercentEncoding!)
        if (urlToOpen != nil)
        {
            let bundle = Bundle(for: type(of:self))
            let storyBoard = UIStoryboard(name: "Main", bundle:bundle)
            let webView = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webView.urlToOpen = urlToOpen!
            webView.schemeURL = self.schemeURL
            webView.addressURL = self.addressURL
            webView.delegate = self
            webView.tintColor = self.tintColor
            webView.backgroundColor = self.backgroundColor
            webView.hideToolbar = self.hideToolbar
            self.present(webView: webView)
        }
    }
    
    public func getWebView() -> WebViewController?
    {
        let urlToOpen = URL(string: self.addressURL.removingPercentEncoding!)
        if (urlToOpen != nil)
        {
            let bundle = Bundle(for: type(of:self))
            let storyBoard = UIStoryboard(name: "Main", bundle:bundle)
            let webView = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webView.urlToOpen = urlToOpen!
            webView.schemeURL = self.schemeURL
            webView.addressURL = self.addressURL
            webView.delegate = self
            webView.tintColor = self.tintColor
            webView.backgroundColor = self.backgroundColor
            webView.hideToolbar = self.hideToolbar

            return webView
        }
        
        return nil
    }
    
    func present(webView: WebViewController)
    {
        UIApplication.shared.windows.first?.rootViewController = webView
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}

private extension URL
{
    var queryDictionary: [String: Any]? {
        var queryStrings = [String: String]()
        guard let query = self.query else { return queryStrings }
        for pair in query.components(separatedBy: "&")
        {
            if (pair.components(separatedBy: "=").count > 1)
            {
                let key = pair.components(separatedBy: "=")[0]
                let value = pair
                    .components(separatedBy: "=")[1]
                    .replacingOccurrences(of: "+", with: " ")
                    .removingPercentEncoding ?? ""
                
                queryStrings[key] = value
            }
        }
        return queryStrings
    }
}

extension MobiFlowSwift: UIApplicationDelegate
{
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        return true
    }
}

extension MobiFlowSwift: MessagingDelegate
{
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?)
    {
        let userDefault = UserDefaults.standard
        userDefault.set(fcmToken, forKey: "TOKEN")
        userDefault.synchronize()
        
        Adjust.setPushToken(fcmToken!)
        print("FCM "+fcmToken!)

        let adjustEvent = ADJEvent(eventToken: adjPushToken)
        adjustEvent?.addCallbackParameter("eventValue", value: fcmToken ?? "")
        let deeplink = UserDefaults.standard.object(forKey: "deeplinkURL") as? String
        adjustEvent?.addCallbackParameter("deeplink", value: deeplink ?? "")
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        adjustEvent?.addCallbackParameter("App_To_Adjust_DeviceId", value: uuid);
        Adjust.trackEvent(adjustEvent)
    }
}

@available(iOS 10, *)
extension MobiFlowSwift : UNUserNotificationCenterDelegate
{
    // Receive displayed notifications for iOS 10 devices.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        let action_id = userInfo["action_id"] as! String
        let deeplink = userInfo["deeplink"] as! String
        if action_id == "1"
        {
            let url = URL(string: deeplink)
            if UIApplication.shared.canOpenURL(url!)
            {
                UIApplication.shared.open(url!)
            }
        }
        
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
                
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    private func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
         if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension MobiFlowSwift: AdjustDelegate
{
    public func adjustAttributionChanged(_ attribution: ADJAttribution?)
    {
        print(attribution?.adid ?? "")
    }
    
    public func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?)
    {
      print(eventSuccessResponseData?.jsonResponse ?? [:])
    }

    public func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?)
    {
      print(eventFailureResponseData?.jsonResponse ?? [:])
    }

    public func adjustSessionTrackingFailed(_ sessionFailureResponseData: ADJSessionFailure?)
    {
      print(sessionFailureResponseData?.jsonResponse ?? [:])
    }
    
    // MARK: - HANDLE Deeplink response
    private func handleDeeplink(deeplink url: URL?)
    {
        print("Handling Deeplink")
        print(url?.absoluteString ?? "Not found")
        UserDefaults.standard.setValue(url?.absoluteString, forKey: "deeplinkURL")
        UserDefaults.standard.synchronize()
        startApp()
    }
    
    public func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool
    {
        handleDeeplink(deeplink: deeplink)
        return true
    }
    
    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool
    {
        // Pass deep link to Adjust in order to potentially reattribute user.
        print("Universal link opened an app:")
        print(url.absoluteString)
        Adjust.appWillOpen(url)
        return true
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("Universal link opened an app: %@", userActivity.webpageURL!.absoluteString)
            if let webURL = userActivity.webpageURL {
                let oldStyleDeeplink = Adjust.convertUniversalLink(webURL, scheme: "e9ua.adj.st")
                handleDeeplink(deeplink: oldStyleDeeplink)
                Adjust.appWillOpen(userActivity.webpageURL!)
            }
        }
        return true
    }
}

extension MobiFlowSwift: WebViewControllerDelegate
{
    func present(dic: [String : Any])
    {
        self.requestPremission()
        self.delegate?.present(dic: dic)
    }
    
    func set(schemeURL: String, addressURL: String)
    {
        self.schemeURL = schemeURL
        self.addressURL = addressURL
    }
    
    func startApp()
    {
        if schemeURL.isEmpty
        {
            if self.customURL.isEmpty
            {
                self.createCustomURL()
            }
            let webView = initWebViewURL()
            self.present(webView: webView)
        }
        else if !self.addressURL.isEmpty
        {
            let urlToOpen = URL(string: self.addressURL.removingPercentEncoding!)
            let bundle = Bundle(for: type(of:self))
            let storyBoard = UIStoryboard(name: "Main", bundle:bundle)
            let webView = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webView.urlToOpen = urlToOpen!
            webView.schemeURL = self.schemeURL
            webView.addressURL = self.addressURL
            webView.delegate = self
            webView.tintColor = self.tintColor
            webView.backgroundColor = self.backgroundColor
            self.present(webView: webView)
        }
        else
        {
            self.requestPremission()
            self.delegate?.present(dic: [String: Any]())
            let url = URL(string: self.schemeURL)
            if UIApplication.shared.canOpenURL(url!)
            {
                UIApplication.shared.open(url!)
            }
        }
    }
}
