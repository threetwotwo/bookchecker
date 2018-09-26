//
//  Categories.swift
//  bookchecker
//
//  Created by Gary on 8/25/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

enum Category {
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


	func parameterValue(apiSource: APISource) -> String {
		switch (self, apiSource) {
		case (.fiction, .google):
			return "Fiction"
		case (.fiction, .archive):
			return "Fiction"
		case (.romance, .google):
			return "Romance"
		case (.romance, .archive):
			return "Romance"
		case (.historicalFiction, .google):
			return "Fiction Historical"
		case (.historicalFiction, .archive):
			return "Fiction Historical"
		case (.scifi, .google):
			return "Fiction / Science Fiction / Space Opera"
		case (.scifi, .archive):
			return "Fiction / Science Fiction / Space Opera"
		case (.horror, .google):
			return "Fiction / Horror"
		case (.horror, .archive):
			return "Fiction / Horror"
		case (.food, .google):
			return "Cooking / Individual Chefs & Restaurants"
		case (.food, .archive):
			return "Cooking / Individual Chefs & Restaurants"
		case (.kids, .google):
			return "Juvenile Fiction / Concepts"
		case (.kids, .archive):
			return "Juvenile Fiction / Concepts"
		case (.fantasy, .google):
			return "Fiction / Fantasy / Epic"
		case (.fantasy, .archive):
			return "Fiction / Fantasy / Epic"
		case (.crime, .google):
			return "Fiction / Crime"
		case (.crime, .archive):
			return "Fiction / Crime"
		case (.business, .google):
			return "Business & Economics / Decision-Making & Problem Solving"
		case (.business, .archive):
			return "Business & Economics / Decision-Making & Problem Solving"
		case (.mystery, .google):
			return "Fiction / Mystery & Detective / General"
		case (.mystery, .archive):
			return "Fiction / Mystery & Detective / General"
		case (.savedCollection,_):
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
