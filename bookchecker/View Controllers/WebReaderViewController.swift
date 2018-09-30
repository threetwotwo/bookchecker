//
//  WebReaderViewController.swift
//  bookchecker
//
//  Created by Gary on 8/19/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift
import GoogleMobileAds

class WebReaderViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var webReaderView: WKWebView!

	@IBOutlet weak var adBannerView: GADBannerView!

	//MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	//MARK: - Variables
	var bookID = ""
	var readerLink: URL!
	var timer: Timer?
	var savedBook: RealmBook?


	//MARK: - Life Cycle
	fileprivate func setUpWebReaderView(url: URL) {
		webReaderView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
		webReaderView.navigationDelegate = self
		let urlRequest = URLRequest(url: readerLink)
		webReaderView.load(urlRequest)
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		if let book = DBManager.shared.getBooks().filter("id == '\(bookID)'").first {
			savedBook = book
		}
		setUpWebReaderView(url: readerLink)
		adBannerView.adUnitID = "ca-app-pub-3632853954476836/8819168571"
		adBannerView.rootViewController = self
		adBannerView.load(GADRequest())
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		guard let savedBook = savedBook else {return}
		webReaderView.evaluateJavaScript("document.getElementsByClassName('overflow-scrolling')[0].scrollTop;") { (result, _) in
			guard let result = result else {return}

			let pageString = String(describing: result)
			try! Realm().write {
				savedBook.currentPage = pageString
			}
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
		}
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress" {
			progressBar.progress = Float(webReaderView.estimatedProgress)
		}
	}
}

// MARK: - WKNavigationDelegate
extension WebReaderViewController: WKNavigationDelegate {
	//Disable links
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		if (navigationAction.navigationType == .linkActivated){
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}

	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		progressBar.alpha = 0.0
		UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
			self.progressBar.alpha = 1.0
		})
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		//Hides header and footer
		self.webReaderView.evaluateJavaScript("document.getElementById('gb-mobile-appbar').remove();", completionHandler: nil)
		if let currentPage = savedBook?.currentPage {
			self.webReaderView.evaluateJavaScript("document.getElementsByClassName('overflow-scrolling')[0].scrollTop = \(currentPage);", completionHandler: nil)
		} else {
			self.webReaderView.evaluateJavaScript("document.getElementsByClassName('overflow-scrolling')[0].scrollTop = 0;", completionHandler: nil)
		}

		UIApplication.shared.isNetworkActivityIndicatorVisible = false

		progressBar.alpha = 1.0
		UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
			self.progressBar.alpha = 0.0
		})
	}
}
