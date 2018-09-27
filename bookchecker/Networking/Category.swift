//
//  Categories.swift
//  bookchecker
//
//  Created by Gary on 8/25/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

enum Category {
	case business
	case crime
	case fantasy
	case fiction
	case food
	case historicalFiction
	case horror
	case kids
	case mystery
	case romance
	case savedCollection
	case scifi


	func parameterValue(apiSource: APISource) -> String {
		switch (self, apiSource) {
		case (.business, .google):
			return "Business & Economics / Decision-Making & Problem Solving"
		case (.business, .archive):
			return "Business & Economics / Decision-Making & Problem Solving"
		case (.crime, .google):
			return "Fiction / Crime"
		case (.crime, .archive):
			return "Fiction / Crime"
		case (.fantasy, .google):
			return "Fiction / Fantasy / Epic"
		case (.fantasy, .archive):
			return "Fiction / Fantasy / Epic"
		case (.fiction, .google):
			return "Fiction"
		case (.fiction, .archive):
			return "Fiction"
		case (.food, .google):
			return "Cooking / Individual Chefs & Restaurants"
		case (.food, .archive):
			return "Cooking / Individual Chefs & Restaurants"
		case (.historicalFiction, .google):
			return "Fiction Historical"
		case (.historicalFiction, .archive):
			return "Fiction Historical"
		case (.horror, .google):
			return "Fiction / Horror"
		case (.horror, .archive):
			return "Fiction / Horror"
		case (.kids, .google):
			return "Juvenile Fiction / Concepts"
		case (.kids, .archive):
			return "Juvenile Fiction / Concepts"
		case (.mystery, .google):
			return "Fiction / Mystery & Detective / General"
		case (.mystery, .archive):
			return "Fiction / Mystery & Detective / General"
		case (.romance, .google):
			return "Romance"
		case (.romance, .archive):
			return "Romance"
		case (.savedCollection,_):
			return ""
		case (.scifi, .google):
			return "Fiction / Science Fiction / Space Opera"
		case (.scifi, .archive):
			return "Fiction / Science Fiction / Space Opera"
		}
	}

	func headerDescription() -> String {
		switch self {
		case .business:
			return "Business"
		case .crime:
			return "Crime"
		case .fantasy:
			return "Fantasy epics"
		case .fiction:
			return "Fiction"
		case .food:
			return "Food & Cooking"
		case .historicalFiction:
			return "Historical Fiction"
		case .horror:
			return "Horror"
		case .kids:
			return "Kids"
		case .mystery:
			return "Mystery"
		case .romance:
			return "Romance"
		case .savedCollection:
			return "Continue Reading"
		case .scifi:
			return "Science Fiction"
		}
	}
}
