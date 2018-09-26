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
		let label = UITextView()
		label.center = self.center
		label.text = message
		label.textColor = UIColor.lightGray
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 18, weight: .light)
		label.textContainerInset = UIEdgeInsets(top: self.frame.height/2.3, left: 20, bottom: 0, right: 20)
		label.isUserInteractionEnabled = false
		self.backgroundView = label
		self.separatorStyle = .none
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
		let label = UITextView()
		label.center = self.center
		label.text = message
		label.textColor = UIColor.lightGray
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 18, weight: .light)
		label.textContainerInset = UIEdgeInsets(top: self.frame.height/2.3, left: 20, bottom: 0, right: 20)
		label.isUserInteractionEnabled = false
		self.backgroundView = label
		self.isScrollEnabled = false

	}

	func restore() {
		self.backgroundView = nil
		self.isScrollEnabled = true
	}
}
