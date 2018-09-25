//
//  Book.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//
import Foundation

struct Book {
	var apiSource = ""
	var language = ""
	var id = ""
	var authors = ""
	var title = ""
	var pageCount = ""
	var publisher = ""
	var publishedDate = ""
	var about = ""
	var averageRating = ""
	var ratingsCount = ""
	var infoLink = ""
	var readerLink = ""
	var downloadLinks: [String] = []
	var thumbnail = ""
	var categories = ""
	var image: Data? = nil
}

extension Book {
	init(realmBook: RealmBook) {
		apiSource = realmBook.apiSource
		language = realmBook.language
		id = realmBook.id
		authors = realmBook.authors
		title = realmBook.title
		pageCount = realmBook.pageCount
		publisher = realmBook.publisher
		publishedDate = realmBook.publishedDate
		about = realmBook.about
		averageRating = realmBook.averageRating
		ratingsCount = realmBook.ratingsCount
		infoLink = realmBook.infoLink
		readerLink = realmBook.readerLink
		thumbnail = realmBook.thumbnail
		categories = realmBook.categories
		image = realmBook.image
		downloadLinks = Array(realmBook.downloadLinks)
	}
}
