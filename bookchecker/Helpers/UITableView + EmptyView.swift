//
//  UITableView + EmptyView.swift
//  bookchecker
//
//  Created by Gary on 9/12/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

extension UITableView {
	func setEmptyMessage(_ message: String) {
		let messageLabel = UILabel()
		messageLabel.center = self.center
		messageLabel.text = message
		messageLabel.textColor = UIColor.lightGray
		messageLabel.numberOfLines = 4;
		messageLabel.textAlignment = .center;
		messageLabel.font = UIFont(name: "Futura-Medium", size: 16)
		messageLabel.sizeToFit()

		self.backgroundView = messageLabel;
		self.separatorStyle = .none;
		self.isScrollEnabled = false

	}

	func restore() {
		self.backgroundView = nil
		self.separatorStyle = .singleLine
		self.isScrollEnabled = true
	}
}

extension UICollectionView {
	func setEmptyMessage(_ message: String) {
		let messageLabel = UILabel()
		messageLabel.center = self.center
		messageLabel.text = message
		messageLabel.textColor = UIColor.lightGray
		messageLabel.numberOfLines = 4;
		messageLabel.textAlignment = .center;
		messageLabel.font = UIFont(name: "Futura-Medium", size: 16)
		messageLabel.sizeToFit()

		self.backgroundView = messageLabel;
		self.isScrollEnabled = false

	}

	func restore() {
		self.backgroundView = nil
		self.isScrollEnabled = true
	}
}
