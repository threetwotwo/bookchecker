//
//  Book.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//
import UIKit
import Foundation

struct Book {
	var authors: String?
	var title: String?
	var subtitle: String?
	var publisher: String?
	var publishedDate: String?
	var description: String?
	var averageRating: String?
	var ratingsCount: String?
	var previewLink: String?
	var thumbnail: String?
	var categories: String?
}

struct BookImage {
	var image: UIImage
}
