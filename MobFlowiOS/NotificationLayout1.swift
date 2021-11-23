//
//  NotificationLayout1.swift
//  MobFlowiOS
//
//  Created by  Vishnu MobiBox on 10/11/21.
//

import UIKit

protocol NotificationLayoutDelegate
{
    func closeNotificationLayout()
}

public class NotificationLayout1: UIViewController {

    @IBOutlet weak private var layoutTitle : UILabel!
    @IBOutlet weak private var layoutDesciption : UILabel!
    @IBOutlet weak private var layoutBackgroundImage: UIImageView!
    @IBOutlet weak private var layoutCloseButton : UIButton!
    @IBOutlet weak private var loadMoreButton : UIButton!
    
    var notificationData : NotificationDataManager?
    var notificationDelegate : NotificationLayoutDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.layoutTitle.text = notificationData?.title ?? ""
        self.layoutDesciption.text = notificationData?.body ?? ""
        
        //load layout Image
        if let imageUrlString = notificationData?.image {
            self.layoutBackgroundImage.downloaded(from: imageUrlString, contentMode: .scaleAspectFill)
        }
        
        self.layoutCloseButton.isHidden = !(notificationData?.show_close_button ?? true)
        
        self.loadMoreButton.isHidden = (notificationData?.deeplink == "")

        print("notificationData : \(notificationData)")
        
    }
    
    @IBAction func closeBtnActn(_ sender: Any) {
        print("close button tapped...")
        self.notificationDelegate?.closeNotificationLayout()
    }
    
    @IBAction func learnMoreBtnActn(_ sender: Any) {
        print("learn More button tapped...")
        
        let showToolBar = notificationData?.show_toolbar_webview ?? false
        let action_id = notificationData?.action_id ?? ""
        
        let deeplinkData = notificationData?.deeplink ?? ""
        
        if (action_id == "1" && deeplinkData != "") {
            let url = URL(string: deeplinkData)
            if (url != nil) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        } else if (action_id == "2" && deeplinkData != "") {
            print("showToolBar: \(showToolBar), deeplinkData: \(deeplinkData)")
            let loadMoreWebView = LearnMoreWebViewController().loadViewController(showToolBar: showToolBar, deeplinkData: deeplinkData, isRootViewController: false)
            self.navigationController?.pushViewController(loadMoreWebView, animated: true)
        }
        
    }
    
}
