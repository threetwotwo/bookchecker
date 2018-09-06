//
//  UIImage + alpha.swift
//  bookchecker
//
//  Created by Gary on 9/6/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

extension UIImage {

	func alpha(_ value:CGFloat) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage!
	}
}
