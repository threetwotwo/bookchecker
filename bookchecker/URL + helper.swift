//
//  URL + helper.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

extension URL {
	func withQueries(_ queries: [String: String]) -> URL? {
		var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
		components?.queryItems = queries.compactMap{URLQueryItem(name: $0.key, value: $0.value)}
		return components?.url
	}
	//helper method to force url request to use the https protocol
	func withHTTPS() -> URL? {
		var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
		components?.scheme = "https"
		return components?.url
	}
}
