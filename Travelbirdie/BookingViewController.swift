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
        let url = URL(string: self.urlString!)
        
        self.webView.loadRequest(URLRequest(url: url!))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
