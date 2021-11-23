//
//  NoInternetViewController.swift
//  Test
//
//  Created by Smart Mobile Tech on 2/8/21.
//

import UIKit
import Reachability

public class NoInternetViewController: UIViewController
{
    @IBOutlet weak private var retryBtn: UIButton! {
        didSet {
            self.retryBtn.titleLabel!.textColor = self.tintColor
            self.retryBtn.backgroundColor = self.backgroundColor
        }
    }
    var isReachable = false
    let reachability = try! Reachability(hostname: "google.com")
    var backgroundColor = UIColor.white
    var tintColor = UIColor.black

    public override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        self.isReachable = true
        break
      case .cellular:
        self.isReachable = true
        break
      case .unavailable:
        self.isReachable = false
        break
      case .none:
        self.isReachable = false
        break
      }
    }

    @IBAction func retryAction(_ sender: UIButton)
    {
        if self.isReachable
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit
    {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }
}
