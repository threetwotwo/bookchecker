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

struct Book {
	var id = ""
	var authors = ""
	var title = ""
	var subtitle = ""
	var publisher = ""
	var publishedDate = ""
	var about = ""
	var averageRating = ""
	var ratingsCount = ""
	var previewLink = ""
	var thumbnail = ""
	var categories = ""
	var image: Data? = nil
}

extension Book {
	init(realmBook: RealmBook) {
		id = realmBook.id
		authors = realmBook.authors
		title = realmBook.title
		subtitle = realmBook.subtitle
		publisher = realmBook.publisher
		publishedDate = realmBook.publishedDate
		about = realmBook.about
		averageRating = realmBook.averageRating
		ratingsCount = realmBook.ratingsCount
		previewLink = realmBook.previewLink
		thumbnail = realmBook.thumbnail
		categories = realmBook.categories
		image = realmBook.image
	}
}
