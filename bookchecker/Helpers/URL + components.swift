//
//  URL + components.swift
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

	mutating func setValue(forKey key: String, to newValue: String) {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
			return
		}

		var parameters = [String: String]()
		for item in queryItems {
			parameters[item.name] = item.value
		}

		parameters[key] = newValue

		components.queryItems = parameters.compactMap{URLQueryItem(name: $0.key, value: $0.value)}

		self = components.url!
	}

	func valueOf(_ queryParamaterName: String) -> String? {
		guard let url = URLComponents(string: self.absoluteString) else { return nil }
		return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
	}
}
