//
//  WebViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/6/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    private struct Constants {
        static let BackButtonImage = UIImage(named: "back")
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var webView: UIWebView! {
        didSet {
            if URL != nil {
                webView.delegate = self
                self.title = URL!.host
                webView.scalesPageToFit = true
                webView.loadRequest(URLRequest(url: URL!))
            }
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Public API
    var URL: Foundation.URL?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(image: Constants.BackButtonImage,
                            style: UIBarButtonItemStyle.plain,
                           target: self,
                    action: #selector(WebViewController.navigateToPreviousWebPageOrVC(_:)))
    }
    
    // MARK: - Users interaction
    @objc private func navigateToPreviousWebPageOrVC(_ sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        } else {
           _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func toRootViewController(_ sender: UIBarButtonItem) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.stopAnimating()
        print("проблемы с загрузкой web страницы!")
    }
}
