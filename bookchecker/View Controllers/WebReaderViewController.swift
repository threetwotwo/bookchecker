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

	//MARK: - Variables
	var previewLink: URL!

	override func viewDidLoad() {
        super.viewDidLoad()
		let urlRequest = URLRequest(url: previewLink)
		webReaderView.load(urlRequest)
    }

}
