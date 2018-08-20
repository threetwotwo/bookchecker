//
//  Book.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//
import UIKit
import Foundation
import RealmSwift

class Book: Object {
	@objc dynamic var authors = ""
	@objc dynamic var title = ""
	@objc dynamic var subtitle = ""
	@objc dynamic var publisher = ""
	@objc dynamic var publishedDate = ""
	@objc dynamic var about = ""
	@objc dynamic var averageRating = ""
	@objc dynamic var ratingsCount = ""
	@objc dynamic var previewLink = ""
	@objc dynamic var thumbnail = ""
	@objc dynamic var categories = ""
}

struct BookImage {
	var image: UIImage
}
