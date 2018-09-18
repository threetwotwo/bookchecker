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
	static var cachedBooks: [APISource:[JSON]] = [:]

	static let shared = Services()
	var docController: UIDocumentInteractionController?
	let dispatchGroup = DispatchGroup()
	static func getfileNamesFromDisk() -> [String] {
		var names = [String]()
		do {
			names = try FileManager.default.contentsOfDirectory(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
		} catch {
			print(error.localizedDescription)
		}
		return names
	}

	//Index is needed to organize feed
	static func createSubjectQueriesWithIndex(queries: Categories...) -> [Int : Categories] {
		var results: [Int : Categories] = [:]
		for i in 0..<queries.count {
			results[i] = queries[i]
		}
		print(results)
		return results
	}

	func extractBooks(from totalItems: [APISource:[JSON]], searchParameter: String) -> [Book]{
		var books: [Book] = []

		for (key,value) in totalItems {
			let index = min(100, totalItems[key]!.count)
			switch key {
			case .google:
				var googleBooks: [Book] = []
				for i in 0..<index {
					guard let totalItems = totalItems[key] else {return books}
					let item = totalItems[i]
					let volumeInfo = item["volumeInfo"]

					var book = Book()
					book.apiSource = key.rawValue
					book.language = volumeInfo["language"].stringValue
					book.id = item["id"].stringValue
					book.title = volumeInfo["title"].stringValue
					book.authors = volumeInfo["authors"].arrayValue.map{$0.stringValue}.joined(separator: ", ")
					book.pageCount = volumeInfo["pageCount"].stringValue
					book.about = String(volumeInfo["description"].stringValue.prefix(2500))
					book.publisher = volumeInfo["publisher"].stringValue
					book.publishedDate = String(volumeInfo["publishedDate"].stringValue.prefix(4))
					book.categories = volumeInfo["categories"].arrayValue.map{$0.stringValue}.joined(separator: ", ")
					book.averageRating = volumeInfo["averageRating"].stringValue
					book.ratingsCount = volumeInfo["ratingsCount"].stringValue
					book.readerLink = item["accessInfo"]["webReaderLink"].stringValue
					book.thumbnail = volumeInfo["imageLinks"]["thumbnail"].stringValue
					book.infoLink = volumeInfo["infoLink"].stringValue

					googleBooks.append(book)
				}
				books.append(contentsOf: googleBooks)
				Services.cachedBooks[.google] = Array(totalItems[key]!.suffix(from: index))

			case .archive:
				var archiveBooks: [Book] = []

				//return at max 10 results
				for i in 0..<index {
					guard let totalItems = totalItems[key] else {return books}
					let item = totalItems[i]
					var book = Book()
					let identifier = item["identifier"].stringValue
					book.apiSource = key.rawValue
					book.id = identifier
					book.title = item["title"].stringValue
					book.authors = item["creator"].stringValue
					book.publishedDate = String(item["publicdate"].stringValue.prefix(4))
					book.about = String(item["description"].stringValue.prefix(2500))
					book.language = item["language"].stringValue
					book.infoLink = "https://archive.org/details/" + item["identifier"].stringValue
					book.categories = item["collection"].arrayValue[0].stringValue

					archiveBooks.append(book)
				}
				books.append(contentsOf: archiveBooks)
				Services.cachedBooks[.archive] = Array(totalItems[key]!.suffix(from: index))
			}
		}
		return books
	}

	static func sortedBooks(_ books: [Book], by term: String) -> [Book] {
		return books.sorted {
			let title1 = $0.title
			let title2 = $1.title

			let key = term.lowercased()

			if title1 == key && title2 != key {
				return true
			} else if title1.hasPrefix(key) && !title2.hasPrefix(key)  {
				return true
			} else if title1.hasPrefix(key) && title2.hasPrefix(key) && title1.count < title2.count  {
				return true
			} else if title1.contains(key) && !title2.contains(key) {
				return true
			} else if title1.contains(key) && title2.contains(key) && title1.count < title2.count {
				return true
			}
			return false
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
				parameters["maxResults"] = "30"
				parameters["download"] = "epub"
				parameters["key"] = "AIzaSyCIkCqynRHXaZfRZ-u2NllyoXwi5vCKWOM"

				Alamofire.request(source.searchURL, parameters: parameters).responseJSON { (response) in
					print("GBS request: \(response.request)")
					print("GBS response code: \(response.response?.statusCode)")

					switch response.result {
					case .success:
						print("GBS: Successful Request")
						guard let json = response.result.value else {
							print("GBS: Cannot get JSON object from result")
							return
						}
						let bookJSON = JSON(json)
						let totalItems = bookJSON["items"].arrayValue
						books.append(contentsOf: self.extractBooks(from: [source:totalItems], searchParameter: searchParameter))
					case .failure:
						print("GBS: BAD Request!")
					}
					self.dispatchGroup.leave()
				}
			case .archive:
				dispatchGroup.enter()

				parameters["fields"] = "title,creator,publisher,publicdate,description,rights,language,collection"
				parameters["q"] = "\(searchParameter) AND (format:epub OR format:pdf) AND (collection:opensource* OR collection:gutenberg OR collection:magazine_rack OR collection:mensmagazines OR collection:comics OR collection:no-preview) AND (NOT subject:religion NOT subject:islam*  NOT subject:1* NOT subject:quran NOT subject:bible NOT subject:*jesus* NOT subject:*christ* NOT subject:*church*) AND mediatype:texts"
				parameters["count"] = "300"

				Alamofire.request(source.searchURL, parameters: parameters).responseJSON { (response) in
					print("ARCHIVE.ORG request: \(response.request)")
					print("ARCHIVE.ORG response code: \(response.response?.statusCode)")
					switch response.result {
					case .success:
						print("ARCHIVE.ORG: Successful Request")
						guard let json = response.result.value else {
							print("ARCHIVE.ORG: Cannot get JSON object from result")
							return
						}
						let bookJSON = JSON(json)
						let totalItems = bookJSON["items"].arrayValue
						books.append(contentsOf: self.extractBooks(from: [source:totalItems], searchParameter: searchParameter))
					case .failure:
						print("Archive.org: BAD request!")
					}
					self.dispatchGroup.leave()
				}
			}
			dispatchGroup.notify(queue: .main) {
//				completion(books)
				completion(Services.sortedBooks(books, by: searchParameter))
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
