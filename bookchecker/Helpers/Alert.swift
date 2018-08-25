//
//  Alert.swift
//  bookchecker
//
//  Created by Gary on 8/24/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

struct Alert {
	static func createAlert<T: UIViewController>(_ vc: T, title: String, message: String?) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		vc.present(ac, animated: true)
	}
}
