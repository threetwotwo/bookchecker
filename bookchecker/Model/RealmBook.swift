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
		apiSource = book.apiSource
		language = book.language
		id = book.id
		authors = book.authors
		title = book.title
		pageCount = book.pageCount
		publisher = book.publisher
		publishedDate = book.publishedDate
		about = book.about
		averageRating = book.averageRating
		ratingsCount = book.ratingsCount
		infoLink = book.infoLink
		readerLink = book.readerLink
		thumbnail = book.thumbnail
		categories = book.categories
		image = book.image
		dateAdded = Date()
	}
	@objc dynamic var apiSource = ""
	@objc dynamic var language = ""
	@objc dynamic var dateAdded: Date = Date()
	@objc dynamic var lastOpened: Date?
	@objc dynamic var id = ""
	@objc dynamic var authors = ""
	@objc dynamic var title = ""
	@objc dynamic var pageCount = ""
	@objc dynamic var currentPage = ""
	@objc dynamic var publisher = ""
	@objc dynamic var publishedDate = ""
	@objc dynamic var about = ""
	@objc dynamic var averageRating = ""
	@objc dynamic var ratingsCount = ""
	@objc dynamic var infoLink = ""
	@objc dynamic var readerLink = ""
	let downloadLinks = List<String>()
	@objc dynamic var thumbnail = ""
	@objc dynamic var categories = ""
	@objc dynamic var image: Data? = nil
}
