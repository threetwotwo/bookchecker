//
//  Services.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//
import UIKit
import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class Services {

	static let baseURL = "https://www.googleapis.com/books/v1/volumes"
	static let shared = Services()

	static func createSubjectQueriesWithIndex(queries: Parameters...) -> [Int : Parameters] {
		var results: [Int : Parameters] = [:]
		for i in 0..<queries.count {
			results[i] = queries[i]
		}
		print(results)
		return results
	}

	func getBooks(from url: String, params: [String : String], completion: @escaping ([Book]) -> ()) {
		var parameters = params
		//only return books that have preview
		parameters["filter"] = "partial"
		//return english books
		parameters["langRestrict"] = "en"
		Alamofire.request(url, parameters: parameters).responseJSON { (response) in
			guard response.result.isSuccess else {
				print(response.result.error?.localizedDescription ?? "Error fetching books")
				return
			}
			let bookJSON = JSON(response.result.value!)
			let totalItems = bookJSON["items"].arrayValue

			var books: [Book] = []

			for item in totalItems {
				let volumeInfo = item["volumeInfo"]

				var book = Book()
				book.id = item["id"].stringValue
				book.title = volumeInfo["title"].stringValue
				book.subtitle = volumeInfo["subtitle"].stringValue
				book.authors = volumeInfo["authors"].arrayValue.map{$0.stringValue}.joined(separator: ", ")
				book.about = volumeInfo["description"].stringValue
				book.publisher = volumeInfo["publisher"].stringValue
				book.publishedDate = String(volumeInfo["publishedDate"].stringValue.prefix(4))
				book.categories = volumeInfo["categories"].arrayValue.map{$0.stringValue}.joined(separator: ", ")
				book.averageRating = volumeInfo["averageRating"].stringValue
				book.ratingsCount = volumeInfo["ratingsCount"].stringValue
				book.previewLink = volumeInfo["previewLink"].stringValue
				book.thumbnail = volumeInfo["imageLinks"]["thumbnail"].stringValue
				
				books.append(book)
			}
			completion(books)
		}
	}

	func getBookImage(from url: String, completion: @escaping (UIImage) -> ()) {
		Alamofire.request(url).responseImage { (response) in
			guard response.result.isSuccess else {
				print(response.result.error?.localizedDescription ?? "Error loading image")
				return
			}
			if let image = response.result.value {
				completion(image)
			}
		}
	}

	func highResImageURL(bookID: String) -> String {
		return "https://books.google.com/books/content/images/frontcover/\(bookID)?fife=w200-h300"
	}
}
