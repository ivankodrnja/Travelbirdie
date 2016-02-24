//
//  BookingViewController.swift
//  Travelbirdie
//
//  Created by Ivan Kodrnja on 21/02/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit


class BookingViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    var urlString: String!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView.delegate = self
        let url = NSURL(string: self.urlString!)
        
        self.webView.loadRequest(NSURLRequest(URL: url!))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
