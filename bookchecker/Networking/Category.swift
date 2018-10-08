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
	case freecomics
	case freemagazines
	case freemanga
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


	func parameterValue() -> String {
		switch self {
		case .business:
			return "Business & Economics / Decision-Making & Problem Solving"
		case .classics:
			return "Fiction / Classics"
		case .comicshumor:
			return "Humor / Form / Comic Strips & Cartoons"
		case .comicsmanga:
			return "Comics & Graphic Novels / Manga / General"
		case .comicsscifi:
			return "Comics & Graphic Novels / Science Fiction"
		case .comicssuperheroes:
			return "Comics & Graphic Novels / Superheroes"
		case .crime:
			return "Fiction / Crime"
		case .fantasy:
			return "Fiction / Fantasy / Epic"
		case .freecomics:
			return "collection:comics AND NOT collection*manga*"
		case .freemagazines:
			return "collection:magazine_rack"
		case .freemanga:
			return "collection:*manga*"
		case .fiction:
			return "Fiction / General"
		case .food:
			return "Cooking / General"
		case .historicalFiction:
			return "Fiction / Historical"
		case .horror:
			return "Fiction / Horror"
		case .kids:
			return "Juvenile Fiction / Concepts"
		case .mystery:
			return "Fiction / Mystery & Detective / General"
		case .romance:
			return "Fiction / Romance / General"
		case .savedCollection:
			return ""
		case .scifi:
			return "Fiction / Science Fiction / Space Opera"
		case .selfhelp:
			return "Self-Help / Personal Growth / General"
		case .youngadult:
			return "Young Adult Fiction"

		}
	}

	func headerDescription() -> String {
		switch self {
		case .business:
			return "New In Business"
		case .classics:
			return "New In Classics"
		case .comicshumor:
			return "New In Comic Strips"
		case .comicsmanga:
			return "New In Manga"
		case .comicsscifi:
			return "New In Sci-fi Comics"
		case .comicssuperheroes:
			return "New In Superhero Comics"
		case .crime:
			return "New In Crime"
		case .fantasy:
			return "New In Fantasy epics"
		case .freecomics:
			return "New Free Comics"
		case .freemagazines:
			return "New Free Magazines"
		case .freemanga:
			return "New Free Manga"
		case .fiction:
			return "New In Fiction"
		case .food:
			return "New In Food & Cooking"
		case .historicalFiction:
			return "New In Historical Fiction"
		case .horror:
			return "New In Horror"
		case .kids:
			return "New In Kids"
		case .mystery:
			return "New In Mystery"
		case .romance:
			return "New In Romance"
		case .savedCollection:
			return "Continue Reading"
		case .scifi:
			return "New In Science Fiction"
		case .selfhelp:
			return "New In Self Help"
		case .youngadult:
			return "New In Young Adult"
		}
	}
}
