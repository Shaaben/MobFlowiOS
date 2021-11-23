//
//  LearnMoreWebViewController.swift
//  MobFlowiOS
//
//  Created by Apple on 22/11/21.
//

import UIKit
import WebKit

class LearnMoreWebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak private var webView: WKWebView!
    
    @IBOutlet weak private var titleLabel: UILabel! {
        didSet {
            
        }
    }
    
    @IBOutlet weak private var closeBtn: UIButton! {
        didSet {
            let image = UIImage(named: "close", in: Bundle(for: type(of:self)), compatibleWith: nil)?.withRenderingMode( .alwaysTemplate)
            self.closeBtn.setImage(image, for: .normal)
            self.closeBtn.addTarget(self, action: #selector(popLoadMoreController), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var toolbarHeightAnchor: NSLayoutConstraint!
    var notificationDelegate : NotificationLayoutDelegate?
    var deeplinkData = ""
    var isShowToolBar = false
    var isRootViewController = false
    
    func loadViewController(showToolBar isShowToolBar: Bool, deeplinkData : String, isRootViewController : Bool) -> LearnMoreWebViewController {
        let bundle = Bundle(for: type(of:self))
        let storyBoard = UIStoryboard(name: "Main", bundle:bundle)
        let vc = storyBoard.instantiateViewController(withIdentifier: "idLearnMoreWebViewController") as! LearnMoreWebViewController
        vc.isShowToolBar = isShowToolBar
        vc.deeplinkData = deeplinkData
        vc.isRootViewController = isRootViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.toolbarHeightAnchor.constant = isShowToolBar ? 50 : 0
        
        if let url = URL(string: deeplinkData) {
            let urlRequest = URLRequest(url: url)
            webView.navigationDelegate = self
            webView.load(urlRequest)
        }
    }
    
    @objc func popLoadMoreController() {
        if (isRootViewController) {
            self.notificationDelegate?.closeNotificationLayout()
        } else {
            print("pop Load More Controller called.")
            self.navigationController?.popViewController(animated: true)
        }
    }
}
