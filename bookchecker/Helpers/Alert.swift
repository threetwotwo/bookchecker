//
//  Alert.swift
//  bookchecker
//
//  Created by Gary on 8/24/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import SwiftMessages

struct Alert {
	static func createAlert<T: UIViewController>(_ vc: T, title: String, message: String?) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		vc.present(ac, animated: true)
	}

	static func showMessage(theme: Theme, title: String, body: String?, displayDuration: Double = 2, buttonTitle: String = "OK", completion: (()->())? = nil) {
		// Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
		// files in the main bundle first, so you can easily copy them into your project and make changes.
		let view = MessageView.viewFromNib(layout: .tabView)

		// Theme message elements with the warning style.
		view.configureTheme(theme)

		// Add a drop shadow.
		view.configureDropShadow()

		// Set message title, body, and icon. Here, we're overriding the default warning
		// image with an emoji character.
		view.configureContent(title: title, body: body, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: buttonTitle) { (_) in
			completion!()
			SwiftMessages.hide()
		}
		// Increase the external margin around the card. In general, the effect of this setting
		// depends on how the given layout is constrained to the layout margins.
//		view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

		// Reduce the corner radius (applicable to layouts featuring rounded corners).
		(view.backgroundView as? CornerRoundingView)?.cornerRadius = 10

		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: displayDuration)
		// Show the message.
		SwiftMessages.show(config: config, view: view)
	}
}
