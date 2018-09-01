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
	let dispatchGroup = DispatchGroup()

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
			book.readerLink = item["accessInfo"]["webReaderLink"].stringValue
			book.thumbnail = volumeInfo["imageLinks"]["thumbnail"].stringValue

			books.append(book)
		}
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
				parameters["maxResults"] = "3"
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
						book.readerLink = item["accessInfo"]["webReaderLink"].stringValue
						book.thumbnail = volumeInfo["imageLinks"]["thumbnail"].stringValue

						books.append(book)
					}
					self.dispatchGroup.leave()
				}
			case .archive:
				dispatchGroup.enter()

				parameters["fields"] = "title,creator,publisher,publicdate,description,rights"
				parameters["q"] = "\(searchParameter) AND mediatype:texts AND collection:opensource"
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
					for i in 0..<min(3, totalItems.count) {
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
					links.append(name)
				}
				completion(links.filter{$0.hasSuffix(".pdf") || $0.hasSuffix(".epub")}.sorted{$0 < $1})
			}
		default:
			completion(links)
		}
	}

	func downloadFile(book: Book, fileName: String) {
//		let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
//		Alamofire.download("https://archive.org/download/TheLordOfTheRingsTheTwoTowers/The%20Lord%20of%20the%20Rings%20%20The%20Two%20Towers.pdf", to: destination).response { (response) in
//			if let error = response.error {
//				print("Failed with error: \(error)")
//			} else {
//				print("Downloaded file successfully")
//			}
//			if let targetURL = response.destinationURL {
//				self.docController = UIDocumentInteractionController(url: targetURL)
//				let url = URL(string:"itms-books:");
//				if UIApplication.shared.canOpenURL(url!) {
//					self.docController!.presentOpenInMenu(from: .zero, in: self.view, animated: true)
//					print("iBooks is installed")
//				} else {
//					print("iBooks is not installed")
//				}
//			}
//		}

		
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
