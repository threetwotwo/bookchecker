//
//  APIRequest.swift
//  bookchecker
//
//  Created by Gary on 8/29/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

struct APIRequest {
	var source: APISource
	var searchURL = ""
	var metadataURL = ""
	var downloadURL = ""

	init(source: APISource) {
		self.source = source
		switch source {
		case .google:
			searchURL = "https://www.googleapis.com/books/v1/volumes"
		case .archive:
			searchURL = "https://archive.org/services/search/v1/scrape?"
			metadataURL = "https://archive.org/metadata"
			downloadURL = "https://archive.org/download"
		}
	}
}

