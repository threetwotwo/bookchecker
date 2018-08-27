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
	@IBOutlet weak var webReaderView: WKWebView!
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!

	//MARK: - Variables
	var previewLink: URL!
	var isReader = false

	override func viewDidLoad() {
        super.viewDidLoad()
		topConstraint.constant = isReader ? -115 : -120
		bottomConstraint.constant = isReader ? -25 : 0
		let urlRequest = URLRequest(url: previewLink)
		webReaderView.load(urlRequest)
    }

}
