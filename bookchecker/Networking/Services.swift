//
//  Services.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//
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
	let dispatchGroup = DispatchGroup()

	static func createSubjectQueriesWithIndex(queries: Categories...) -> [Int : Categories] {
		var results: [Int : Categories] = [:]
		for i in 0..<queries.count {
			results[i] = queries[i]
		}
		print(results)
		return results
	}

	func getBooks(from apiSources: APISource..., searchParameter: String, completion: @escaping ([Book]) -> ()) {
		var books: [Book] = []
		for source in apiSources {
			var parameters: [String : String] = [:]
			switch source {
			case .google:
				dispatchGroup.enter()

				parameters["q"] = searchParameter
				//only return books that have preview
				parameters["filter"] = "ebooks"
				//return english books
				parameters["langRestrict"] = "en"
				//number of books
				parameters["maxResults"] = "5"
				parameters["download"] = "epub"

				Alamofire.request(source.searchURL, parameters: parameters).responseJSON { (response) in
					guard response.result.isSuccess else {
						print(response.result.error?.localizedDescription ?? "Error fetching books")
						return
					}
					let bookJSON = JSON(response.result.value!)
					let totalItems = bookJSON["items"].arrayValue
					for item in totalItems {
						let volumeInfo = item["volumeInfo"]

						var book = Book()
						book.apiSource = source.rawValue
						book.language = volumeInfo["language"].stringValue
						book.id = item["id"].stringValue
						book.title = volumeInfo["title"].stringValue
						book.authors = volumeInfo["authors"].arrayValue.map{$0.stringValue}.joined(separator: ", ")
						book.pageCount = volumeInfo["pageCount"].stringValue
						book.about = volumeInfo["description"].stringValue
						book.publisher = volumeInfo["publisher"].stringValue
						book.publishedDate = String(volumeInfo["publishedDate"].stringValue.prefix(4))
						book.categories = volumeInfo["categories"].arrayValue.map{$0.stringValue}.joined(separator: ", ")
						book.averageRating = volumeInfo["averageRating"].stringValue
						book.ratingsCount = volumeInfo["ratingsCount"].stringValue
						book.readerLink = item["accessInfo"]["webReaderLink"].stringValue
						book.thumbnail = volumeInfo["imageLinks"]["thumbnail"].stringValue
						book.infoLink = volumeInfo["infoLink"].stringValue

						books.append(book)
					}
					self.dispatchGroup.leave()
				}
			case .archive:
				dispatchGroup.enter()

				parameters["fields"] = "title,creator,publisher,publicdate,description,rights,language"
				parameters["q"] = "\(searchParameter) AND (format:epub OR format:pdf)AND (collection:opensource*)"
				parameters["count"] = "100"
				parameters["sorts"] = "downloads desc"

				Alamofire.request(source.searchURL, parameters: parameters).responseJSON { (response) in
					guard response.result.isSuccess else {
						print(response.result.error?.localizedDescription ?? "Error fetching books")
						return
					}

					let bookJSON = JSON(response.result.value!)
					let totalItems = bookJSON["items"].arrayValue
					//return at max 10 results
					for i in 0..<min(40, totalItems.count) {
						let item = totalItems[i]
						var book = Book()
						let identifier = item["identifier"].stringValue
						book.apiSource = source.rawValue
						book.id = identifier
						book.title = item["title"].stringValue
						book.authors = item["creator"].stringValue
						book.publisher = item["creator"].stringValue
						book.publishedDate = String(item["publicdate"].stringValue.prefix(4))
						book.about = item["description"].stringValue
						book.language = item["language"].stringValue
						book.infoLink = "https://archive.org/details/" + item["identifier"].stringValue

						books.append(book)
					}
					self.dispatchGroup.leave()
				}
			}
			dispatchGroup.notify(queue: .main) {
				completion(books)
			}
		}
	}

	func getDownloadLinks(book: Book, completion: @escaping ([String]) -> ()) {
		var links: [String] = []
		switch book.apiSource {
		case APISource.archive.rawValue:
			let url = "https://archive.org/metadata/" + book.id
			Alamofire.request(url).responseJSON { (response) in
				guard response.result.isSuccess else {
					print(response.result.error?.localizedDescription ?? "Error fetching books")
					return
				}
				let linksJSON = JSON(response.result.value as Any)
				let files = linksJSON["files"].arrayValue
				for file in files {
					let name = file["name"].stringValue
					if name.hasSuffix(".pdf") || name.hasSuffix(".epub") {
						links.append(name)
					}
				}
				completion(links)
			}
		default:
			completion(links)
		}
	}

	static func getBookImageURL(apiSource: String, identifier: String) -> URL? {
		var url = ""
		switch apiSource {
		case APISource.google.rawValue:
			url = APISource.google.imageURL + "\(identifier)?fife=w200-h300"
		case APISource.archive.rawValue:
			url = APISource.archive.imageURL + identifier
		default:
			break
		}
		return URL(string: url)
	}
}
