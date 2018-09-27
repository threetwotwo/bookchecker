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
	case classics
	case comicshumor
	case comicsmanga
	case comicsscifi
	case comicssuperheroes
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
	case selfhelp
	case youngadult


	func parameterValue(apiSource: APISource) -> String {
		switch (self, apiSource) {
		case (.business, .google):
			return "Business & Economics / Decision-Making & Problem Solving"
		case (.business, .archive):
			return ""
		case (.classics, .google):
			return "Fiction / Classics"
		case (.classics, .archive):
			return ""
		case (.comicshumor, .google):
			return "Humor / Form / Comic Strips & Cartoons"
		case (.comicshumor, .archive):
			return ""
		case (.comicsmanga, .google):
			return "Comics & Graphic Novels / Manga / General"
		case (.comicsmanga, .archive):
			return ""
		case (.comicsscifi, .google):
			return "Comics & Graphic Novels / Science Fiction"
		case (.comicsscifi, .archive):
			return ""
		case (.comicssuperheroes, .google):
			return "Comics & Graphic Novels / Superheroes"
		case (.comicssuperheroes, .archive):
			return ""
		case (.crime, .google):
			return "Fiction / Crime"
		case (.crime, .archive):
			return ""
		case (.fantasy, .google):
			return "Fiction / Fantasy / Epic"
		case (.fantasy, .archive):
			return ""
		case (.fiction, .google):
			return "Fiction"
		case (.fiction, .archive):
			return ""
		case (.food, .google):
			return "Cooking / General"
		case (.food, .archive):
			return ""
		case (.historicalFiction, .google):
			return "Fiction / Historical"
		case (.historicalFiction, .archive):
			return ""
		case (.horror, .google):
			return "Fiction / Horror"
		case (.horror, .archive):
			return "horror"
		case (.kids, .google):
			return "Juvenile Fiction / Concepts"
		case (.kids, .archive):
			return ""
		case (.mystery, .google):
			return "Fiction / Mystery & Detective / General"
		case (.mystery, .archive):
			return ""
		case (.romance, .google):
			return "Fiction / Romance / General"
		case (.romance, .archive):
			return ""
		case (.savedCollection,_):
			return ""
		case (.scifi, .google):
			return "Fiction / Science Fiction / Space Opera"
		case (.scifi, .archive):
			return ""
		case (.selfhelp, .google):
			return "Self-Help / Personal Growth / General"
		case (.selfhelp, .archive):
			return ""
		case (.youngadult, .google):
			return "Young Adult Fiction"
		case (.youngadult, .archive):
			return ""
		}
	}

	func headerDescription() -> String {
		switch self {
		case .business:
			return "Business"
		case .classics:
			return "Classics"
		case .comicshumor:
			return "Fun Comics"
		case .comicsmanga:
			return "Manga"
		case .comicsscifi:
			return "Sci-fi Comics"
		case .comicssuperheroes:
			return "Superhero Comics"
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
		case .selfhelp:
			return "Self Help"
		case .youngadult:
			return "Young Adult"
		}
	}
}
