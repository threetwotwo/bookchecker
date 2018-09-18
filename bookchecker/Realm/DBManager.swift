//
//  DBManager.swift
//  bookchecker
//
//  Created by Gary on 8/24/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import RealmSwift

class DBManager {
	private var realm: Realm
	
	static let shared = DBManager()

	private init() {
		realm = try! Realm()
	}

	func getBooks() -> Results<RealmBook> {
		let results: Results<RealmBook> =   realm.objects(RealmBook.self)
		return results
	}
	
	func addBook(object: RealmBook)   {
		do {
			try realm.write {
				realm.add(object)
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	func saveToFavorites(book: Book) {
		//Check if book has already been added
		let bookIDs = DBManager.shared.getBooks().map{$0.id}
		guard !bookIDs.contains(book.id) else {
			return
		}
		let realmBook = RealmBook(book: book)

		DBManager.shared.addBook(object: realmBook)
	}

	func updateBook(object: RealmBook)   {
		do {
			try realm.write {
				realm.add(object, update: true)
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	func deleteAll()  {
		do {
			try realm.write {
				realm.deleteAll()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	func delete(object: RealmBook)   {
		do {
			try realm.write {
				realm.delete(object)
			}
		} catch {
			print(error.localizedDescription)
		}
	}
}
