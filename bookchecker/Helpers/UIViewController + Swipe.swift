//
//  UIViewController + Swipe.swift
//  bookchecker
//
//  Created by Gary on 9/21/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

extension UIViewController {
	func addSwipeGesturesForSwitchingTabs() {
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
		swipeRight.direction = UISwipeGestureRecognizer.Direction.right
		self.view.addGestureRecognizer(swipeRight)

		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
		swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
		self.view.addGestureRecognizer(swipeLeft)
	}

	@objc func swiped(_ gesture: UISwipeGestureRecognizer) {
		if gesture.direction == .left {
			if (self.tabBarController?.selectedIndex)! < 3 { // set your total tabs here
				self.tabBarController?.selectedIndex += 1
			}
		} else if gesture.direction == .right {
			if (self.tabBarController?.selectedIndex)! > 0 {
				self.tabBarController?.selectedIndex -= 1
			}
		}
	}
}

//extension UIViewController: UITabBarControllerDelegate  {
//	private func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//		guard let fromView = self.view, let toView = viewController.view else {
//			return false // Make sure you want this as false
//		}
//
//		if fromView != toView {
//			UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
//		}
//
//		return true
//	}
//}
