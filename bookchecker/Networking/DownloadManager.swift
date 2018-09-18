//
//  DownloadManager.swift
//  bookchecker
//
//  Created by Gary on 9/18/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import Alamofire

class DownloadManager {
	private var resumeData: Data?
	var docController: UIDocumentInteractionController!

	static let shared = DownloadManager()

	func downloadFile(url: String, fileName: String, progressCompletion: @escaping (Float) -> (), fileURLCompletion: @escaping (URL) -> ()) {

		let request: DownloadRequest
		let destination: DownloadRequest.DownloadFileDestination = { _, _ in
			let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let fileURL = documentsURL.appendingPathComponent(fileName)

			return (fileURL, [.removePreviousFile])
		}

		if let resumeData = resumeData {
			request = Alamofire.download(resumingWith: resumeData, to: destination)
		} else {
			request = Alamofire.download(url, to: destination)
		}

		request.downloadProgress { (progress) in
			progressCompletion(Float(progress.fractionCompleted))
			}
			.response { (response) in
				if let error = response.error {
					print("Failed with error: \(error)")
				} else {
					print("Downloaded file successfully")
					if let targetURL = response.destinationURL {
						print(targetURL)
						fileURLCompletion(targetURL)
					}
				}
		}
	}
}
