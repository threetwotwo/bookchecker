//
//  RealmBook.swift
//  bookchecker
//
//  Created by Gary on 8/24/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import RealmSwift

class RealmBook: Object {

	convenience required init(book: Book) {
		self.init()
		id = book.id
		authors = book.authors
		title = book.title
		subtitle = book.subtitle
		publisher = book.publisher
		publishedDate = book.publishedDate
		about = book.about
		averageRating = book.averageRating
		ratingsCount = book.ratingsCount
		previewLink = book.previewLink
		readerLink = book.readerLink
		thumbnail = book.thumbnail
		categories = book.categories
		image = book.image
	}

	@objc dynamic var id = ""
	@objc dynamic var authors = ""
	@objc dynamic var title = ""
	@objc dynamic var subtitle = ""
	@objc dynamic var publisher = ""
	@objc dynamic var publishedDate = ""
	@objc dynamic var about = ""
	@objc dynamic var averageRating = ""
	@objc dynamic var ratingsCount = ""
	@objc dynamic var previewLink = ""
	@objc dynamic var readerLink = ""
	@objc dynamic var thumbnail = ""
	@objc dynamic var categories = ""
	@objc dynamic var image: Data? = nil
}
