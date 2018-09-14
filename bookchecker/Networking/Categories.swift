//
//  Categories.swift
//  bookchecker
//
//  Created by Gary on 8/25/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

enum Categories {
	case savedCollection
	case fiction
	case romance
	case historicalFiction
	case scifi
	case horror
	case food
	case kids
	case fantasy
	case crime
	case business
	case mystery


	func parameterValue() -> String {
		switch self {
		case .fiction:
			return "Fiction"
		case .romance:
			return "Romance"
		case .historicalFiction:
			return "Fiction Historical"
		case .scifi:
			return "Fiction / Science Fiction / Space Opera"
		case .horror:
			return "Fiction / Horror"
		case .food:
			return "Cooking / Individual Chefs & Restaurants"
		case .kids:
			return "Juvenile Fiction / Concepts"
		case .fantasy:
			return "Fiction / Fantasy / Epic"
		case .crime:
			return "Fiction / Crime"
		case .business:
			return "Business & Economics / Decision-Making & Problem Solving"
		case .mystery:
			return "Fiction / Mystery & Detective / General"
		case .savedCollection:
			return ""
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
		case .scifi:
			return "Science Fiction"
		case .horror:
			return "Horror"
		case .food:
			return "Food & Cooking"
		case .kids:
			return "Kids"
		case .fantasy:
			return "Fantasy epics"
		case .crime:
			return "Crime"
		case .business:
			return "Business"
		case .mystery:
			return "Mystery"
		case .savedCollection:
			return "Continue Reading"
		}
	}
}
