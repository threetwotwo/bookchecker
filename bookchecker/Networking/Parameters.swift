//
//  Parameters.swift
//  bookchecker
//
//  Created by Gary on 8/25/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

enum Parameters {
	case fiction
	case romance
	case historicalFiction


	func parameterValue() -> String {
		switch self {
		case .fiction:
			return "Fiction"
		case .romance:
			return "Romance"
		case .historicalFiction:
			return "Fiction Historical"
		}
	}

	func headerDescription() -> String {
		switch self {
		case .fiction:
			return "Fiction"
		case .romance:
			return "Romance"
		case .historicalFiction:
			return "Historical Fiction"
		}
	}
}
