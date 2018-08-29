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
import SwiftyJSON

class Services {

	static let baseURL = "https://www.googleapis.com/books/v1/volumes"
	static let archiveURL = ""
	static let archiveMetadataURL = "https://archive.org/metadata"
	static let archiveDownloadURL = "https://archive.org/download"


	static let shared = Services()
	var docController: UIDocumentInteractionController?

	static func createSubjectQueriesWithIndex(queries: Categories...) -> [Int : Categories] {
		var results: [Int : Categories] = [:]
		for i in 0..<queries.count {
			results[i] = queries[i]
		}
		print(results)
		return results
	}

	fileprivate func getBooks(from bookJSON: JSON, _ books: inout [Book]) {
		let totalItems = bookJSON["items"].arrayValue
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
			book.readerLink = item["accessInfo"]["webReaderLink"].stringValue
			book.thumbnail = volumeInfo["imageLinks"]["thumbnail"].stringValue

			books.append(book)
		}
	}

	func getBooks(from apiSources: APISource..., searchParameter: String, completion: @escaping ([Book]) -> ()) {
		var books: [Book] = []
		for source in apiSources {
			let apiRequest = APIRequest(source: source)
			var parameters: [String : String] = [:]
			switch source {
			case .google:
				parameters = ["q" : searchParameter]
				//only return books that have preview
				parameters["filter"] = "partial"
				//return english books
				parameters["langRestrict"] = "en"

				Alamofire.request(apiRequest.searchURL, parameters: parameters).responseJSON { (response) in
					guard response.result.isSuccess else {
						print(response.result.error?.localizedDescription ?? "Error fetching books")
						return
					}
					let bookJSON = JSON(response.result.value!)
					let totalItems = bookJSON["items"].arrayValue
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
						book.readerLink = item["accessInfo"]["webReaderLink"].stringValue
						book.thumbnail = volumeInfo["imageLinks"]["thumbnail"].stringValue

						books.append(book)
					}
					completion(books)
				}
			case .archive:
				break
			}
		}
	}

	func downloadBook(url: String) {
		let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
		Alamofire.download(url, to: destination).response { (response) in
			if let error = response.error {
				print("Failed with error: \(error)")
			} else {
				print("Downloaded file successfully")
			}
		}
	}

	func highResImageURL(bookID: String) -> URL? {
		let url = "https://books.google.com/books/content/images/frontcover/\(bookID)?fife=w200-h300"
		return URL(string: url)
	}
}
