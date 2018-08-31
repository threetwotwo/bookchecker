//
//  WebReaderViewController.swift
//  bookchecker
//
//  Created by Gary on 8/19/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import WebKit

class WebReaderViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var webReaderView: WKWebView!
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!

	//MARK: - Variables
	var previewLink: URL!
	var isReader = false

	fileprivate func adjustConstraints() {
		topConstraint.constant = isReader ? -95 : -120
		bottomConstraint.constant = isReader ? -30 : 0
	}

	fileprivate func setUpWebReaderView(url: URL) {
		webReaderView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
		webReaderView.navigationDelegate = self
		let urlRequest = URLRequest(url: url)
		webReaderView.load(urlRequest)

	}

	override func viewDidLoad() {
        super.viewDidLoad()
		setUpWebReaderView(url: previewLink)
    }

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress" {
			progressBar.progress = Float(webReaderView.estimatedProgress)
		}
	}
}

// MARK: - WKNavigationDelegate
extension WebReaderViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		progressBar.alpha = 0.0
		UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
			self.progressBar.alpha = 1.0
		})
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		//Hides header and footer
		webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-topbar-table')[0].style.visibility = 'hidden';", completionHandler: nil)
		webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-statusbar-controls-table')[0].style.visibility = 'hidden';", completionHandler: nil)
		UIApplication.shared.isNetworkActivityIndicatorVisible = false

		progressBar.alpha = 1.0
		UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
			self.progressBar.alpha = 0.0
		})
	}
}
