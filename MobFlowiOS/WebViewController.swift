//
//  WebViewController.swift
//  MobFlow
//
//  Created by Smart Mobile Tech on 2/9/21.
//

import UIKit
import WebKit
import Reachability

protocol WebViewControllerDelegate
{
    func set(schemeURL: String, addressURL: String)
    func startApp()
    func present(dic: [String: Any])
}

class WebViewController: UIViewController
{
    @IBOutlet weak private var webView: WKWebView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var closeBtn: UIButton!
    @IBOutlet weak private var toolbar: UIView!
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    
    var urlToOpen = URL(string: "")
    var schemeURL = ""
    var addressURL = ""
    let reachability = try! Reachability(hostname: "google.com")
    var delegate : WebViewControllerDelegate? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let request = URLRequest(url: self.urlToOpen!)
        self.webView.navigationDelegate = self
        self.webView.load(request)
        let urlToOpen = URL(string: self.addressURL.removingPercentEncoding!)
        if (urlToOpen != nil)
        {
            self.toolbar.isHidden = false
            toolbarHeight.constant = 50
            self.toolbar.layoutIfNeeded()
        }
        else
        {
            self.toolbar.isHidden = true
            toolbarHeight.constant = 0
            self.toolbar.layoutIfNeeded()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do
        {
            try reachability.startNotifier()
        }
        catch
        {
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification)
    {
      let reachability = note.object as! Reachability
      switch reachability.connection
      {
      case .wifi:
        break
      case .cellular:
        break
      case .unavailable:
        self.presentNoInternetViewController()
        break
      case .none:
        break
      }
    }
    
    deinit
    {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }
}

extension WebViewController: WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print("Started to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        print("Finished loading")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        decisionHandler(WKNavigationActionPolicy.allow)
        if let url = navigationAction.request.url
        {
            if (url.queryDictionary!["sName"] != nil)
            {
                self.titleLabel.text = url.queryDictionary!["sName"] as? String
            }
            if UIApplication.shared.canOpenURL(url) && !url.absoluteString.hasPrefix("http")
            {
                self.schemeURL = url.absoluteString
                if(url.query != nil)
                {
                    self.addressURL = url.query!
                }
                self.delegate!.set(schemeURL: self.schemeURL, addressURL: self.addressURL)
                self.delegate!.startApp()
            }
        }
    }
    
    @IBAction func dismissWebView(_ sender: UIButton)
    {
        let url = URL(string: schemeURL)
        let dic = (url?.queryDictionary)!
        self.delegate!.present(dic: dic)
    }
    
    func presentNoInternetViewController()
    {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let view = storyBoard.instantiateViewController(withIdentifier: "NoInternetViewController") as! NoInternetViewController
        self.present(view, animated: true, completion: nil)
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

