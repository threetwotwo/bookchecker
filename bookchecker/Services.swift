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

	func getBooksData(from url: String, params: [String : String], completion: @escaping ([UIImage]) -> ()) {
		Alamofire.request(url, parameters: params).responseJSON { (response) in
			guard response.result.isSuccess else {
				print(response.result.error?.localizedDescription ?? "Error fetching books")
				return
			}
			let bookJSON = JSON(response.result.value!)
			let totalItems = bookJSON["items"].arrayValue
			var images: [UIImage] = []

			for item in totalItems {
				let imageUrl = item["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
				Alamofire.request(imageUrl).responseData { (response) in
					if let data = response.result.value,
					let	image = UIImage(data: data) {
						images.append(image)
					}
					completion(images)
				}
			}
		}
	}

	func getBooks(from url: String, params: [String : String], completion: @escaping ([Book]) -> ()) {
		Alamofire.request(url, parameters: params).responseJSON { (response) in
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
				book.title = volumeInfo["title"].stringValue
				book.subtitle = volumeInfo["subtitle"].stringValue
				book.authors = volumeInfo["authors"].arrayValue.map{$0.stringValue}.joined(separator: ", ")
				book.description = volumeInfo["description"].stringValue
				book.publisher = volumeInfo["publisher"].stringValue
				book.publishedDate = volumeInfo["publishedDate"].stringValue
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
}
