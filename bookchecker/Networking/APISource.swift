//
//  APISource.swift
//  bookchecker
//
//  Created by Gary on 8/29/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

enum APISource: String {
	case google = "Google Books"
	case archive = "archive.org"

	var searchURL: String {
		switch self {
		case .google:
			return "https://www.googleapis.com/books/v1/volumes"
		case .archive:
			return "https://archive.org/services/search/v1/scrape"
		}
	}

	var imageURL: String {
		switch self {
		case .google:
			return "https://books.google.com/books/content/images/frontcover/"
		case .archive:
			return "https://archive.org/services/img/"
		}
	}

	var downloadURL: String {
		switch self {
		case .google:
			return ""
		case .archive:
			return "https://archive.org/download/"
		}
	}

}
