//
//  String + contains.swift
//  bookchecker
//
//  Created by Gary on 9/5/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

extension String {
	func contains(_ string: String) -> Bool {
		return range(of: string, options: .caseInsensitive) != nil
	}
}
