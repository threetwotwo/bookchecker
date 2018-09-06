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

class WebReaderViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var webReaderView: WKWebView!
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!

	//MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	//MARK: - Variables
	var bookID = ""
	var previewLink: URL!
	var timer: Timer?


	//MARK: - Life Cycle
	fileprivate func setUpWebReaderView(url: URL) {
		webReaderView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
		webReaderView.navigationDelegate = self

		let urlRequest = URLRequest(url: previewLink)
		webReaderView.load(urlRequest)
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		setUpWebReaderView(url: previewLink)
		print(previewLink)
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		if let book = DBManager.shared.getBooks().filter("id == '\(bookID)'").first {
			print(webReaderView.url?.absoluteURL)
			try! Realm().write {
				book.currentPage = webReaderView.url?.absoluteURL.valueOf("pg") ?? ""
			}
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
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		progressBar.alpha = 0.0
		UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
			self.progressBar.alpha = 1.0
		})
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		//Hides header and footer

		self.webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-topbar-table')[0].style.visibility = 'hidden';", completionHandler: nil)
		self.webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-statusbar-controls-table')[0].style.visibility = 'hidden';", completionHandler: nil)

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-page-wrapper-body')[0].style.paddingTop = '90px';", completionHandler: nil)
			self.webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-page-wrapper-body')[1].style.paddingTop = '90px';", completionHandler: nil)
			self.webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-page-wrapper-body')[0].style.paddingLeft = '10px';", completionHandler: nil)
			self.webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-page-wrapper-body')[1].style.paddingLeft = '10px';", completionHandler: nil)
			self.webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-page-wrapper-body')[0].style.paddingRight = '10px';", completionHandler: nil)
			self.webReaderView.evaluateJavaScript("document.getElementsByClassName('gb-page-wrapper-body')[1].style.paddingRight = '10px';", completionHandler: nil)
		}


		UIApplication.shared.isNetworkActivityIndicatorVisible = false

		progressBar.alpha = 1.0
		UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
			self.progressBar.alpha = 0.0
		})
	}
}
