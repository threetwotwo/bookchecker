//
//  ViewController + UI.swift
//  bookchecker
//
//  Created by Gary on 8/20/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import  UIKit

struct Navbar {
	 	static func addImage<T: UIViewController>(to vc: T) {
		let navController = vc.navigationController!

		let image = #imageLiteral(resourceName: "logo_happy")
		let imageView = UIImageView(image: image)

		let bannerWidth = navController.navigationBar.frame.size.width
		let bannerHeight = navController.navigationBar.frame.size.height

		let bannerX = bannerWidth / 2 - image.size.width / 2
		let bannerY = bannerHeight / 2 - image.size.height / 2

		imageView.frame = CGRect(x: bannerX, y: bannerY, width: 200, height: bannerHeight)
		imageView.contentMode = .scaleAspectFit

		vc.navigationItem.titleView = imageView
	}
}
