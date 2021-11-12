//
//  NotificationLayout1.swift
//  MobFlowiOS
//
//  Created by  Vishnu MobiBox on 10/11/21.
//

import UIKit

public class NotificationLayout1: UIViewController {

    @IBOutlet weak private var layoutTitle : UILabel!
    @IBOutlet weak private var layoutDesciption : UILabel!
    @IBOutlet weak private var layoutBackgroundImage: UIImageView!
    @IBOutlet weak private var layoutCloseButton : UIButton!
    @IBOutlet weak private var loadMoreButton : UIButton!
    
    var notificationData : NotificationDataManager?
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.layoutTitle.text = notificationData?.title ?? ""
        self.layoutDesciption.text = notificationData?.body ?? ""
        
        //load layout Image
//        self.layoutBackgroundImage
        
        self.layoutCloseButton.isHidden = notificationData?.show_close_button ?? true
        
    }
    
    @IBAction func closeBtnActn(_ sender: Any) {
        
    }
    
    @IBAction func learnMoreBtnActn(_ sender: Any) {
        
    }
    
}
