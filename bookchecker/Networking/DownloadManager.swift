//
//  DownloadManager.swift
//  bookchecker
//
//  Created by Gary on 9/18/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class DownloadManager {
	private var resumeData: Data?
	var docController: UIDocumentInteractionController!

	static let shared = DownloadManager()

	func downloadFile(url: String, fileName: String, progressCompletion: @escaping (Float) -> (), fileURLCompletion: @escaping (URL) -> ()) {

		DBManager.shared.addDownload(fileName: fileName)
		let request: DownloadRequest
		let destination: DownloadRequest.DownloadFileDestination = { _, _ in
			let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let fileURL = documentsURL.appendingPathComponent(fileName)

			return (fileURL, [.removePreviousFile])
		}

		if let resumeData = resumeData {
			request = Alamofire.download(resumingWith: resumeData, to: destination)
			print("Resume data: \(resumeData)")
		} else {
			request = Alamofire.download(url, to: destination)
			print("No resume data")
		}

		request.responseData { response in
			
			switch response.result {
			case .success:
				if let targetURL = response.destinationURL {
				print(response.resumeData)
				fileURLCompletion(targetURL)
			}
			case .failure:
				print("Failed with error: \(response.error)")
				self.resumeData = response.resumeData
			}
			}.downloadProgress { (progress) in
				progressCompletion(Float(progress.fractionCompleted))
		}
	}
}
