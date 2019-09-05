//
//  WebViewController.swift
//  BloggerApp
//
//  Created by IMCS2 on 8/16/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import WebKit
import CoreData
import Foundation
import SystemConfiguration

class WebViewController: UIViewController,WKUIDelegate {
    @IBOutlet weak var LabelDisplay: UILabel?
    
    var bTitle:String = " "
    var contentTotal:String = " "
    var urlInitial:String = " "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let html = """
        <html>
        <head>
        
        </head>
        <body>
        <h1 style="color:red; font-size:50px" align="center">No Internet Connection</h1>
        <p style="color:red; font-size:50px" align="center"> \(urlInitial) </p>
        </body>
        
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
        LabelDisplay?.text = bTitle
        
        let myURL = URL(string:urlInitial)
        
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        if isConnectedToNetwork() == false {
            
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    @IBOutlet var webView: WKWebView!
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
