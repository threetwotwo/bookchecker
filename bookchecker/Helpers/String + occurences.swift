//
//  String + occurences.swift
//  bookchecker
//
//  Created by Gary on 9/1/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

extension String {
	/// stringToFind must be at least 1 character.
	func countInstances(of stringToFind: String) -> Int {
		assert(!stringToFind.isEmpty)
		var count = 0
		var searchRange: Range<String.Index>?
		while let foundRange = range(of: stringToFind, options: [], range: searchRange) {
			count += 1
			searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
		}
		return count
	}
}
