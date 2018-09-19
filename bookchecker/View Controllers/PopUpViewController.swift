//
//  PopUpViewController.swift
//  bookchecker
//
//  Created by Gary on 9/1/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import Alamofire
import SwiftMessages
import RealmSwift

class PopUpViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var popupTableView: UITableView!
	@IBOutlet weak var heightConstraint: NSLayoutConstraint!

	//MARK: - IBActions
	@IBAction func closePopUp(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	//MARK: - Variables
	var book: Book!
	var bookIdentifier: String!
	var bookTitle: String?
	var fileNames: [String]!
	var diskFileNames: [String] = []
	var downloads = DBManager.shared.getDownloads()
	var timer = Timer()

	private var myContext = 0

	//MARK: - Life Cycle
	override func viewDidLoad() {
        super.viewDidLoad()
		bookIdentifier = book.id
		bookTitle = book.title
		fileNames = book.downloadLinks
		diskFileNames = Services.getfileNamesFromDisk()
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		//table view content + button height
		let contentHeight = popupTableView.contentSize.height + 30
		//set pop up view maximum height to 400
		heightConstraint.constant = min(contentHeight, 400)
		//scroll indicator insets
		popupTableView.scrollIndicatorInsets = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
	}

	//MARK: - UI
	fileprivate func showProgressBar(for cell: PopUpTableViewCell, progress: Float = 0) {
		cell.filenameLabel.isHidden = true
		cell.downloadIcon.isHidden = true
		cell.progressBar.isHidden = false
	}

	fileprivate func hideProgressBar(for cell: PopUpTableViewCell) {
		cell.filenameLabel.isHidden = false
		cell.downloadIcon.isHidden = false
		cell.progressBar.isHidden = true
	}

	fileprivate func updateDownloadIcon(_ name: String, _ cell: PopUpTableViewCell) {
		if let encodedFileName = getEncodedFileName(from: name),
			diskFileNames.contains(encodedFileName){
			cell.downloadIcon.image = #imageLiteral(resourceName: "checkmark_green")
		} else {
			cell.downloadIcon.image = #imageLiteral(resourceName: "download")
		}
	}
}

//MARK: - UITableViewDataSource
extension PopUpViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return fileNames.isEmpty ? "No files available" : "Select file to open"
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fileNames.count
	}

	func getReadableFileName(from name: String) -> String {
		if let index = (name.range(of: "-")?.upperBound), name.countInstances(of: ".") > 1 {
			return String(name.suffix(from: index))
		} else {
			return name
		}
	}

	func getEncodedFileName(from name: String) -> String? {
		return getReadableFileName(from: name).replacingOccurrences(of: "/", with: ",")
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpCell", for: indexPath) as! PopUpTableViewCell
		hideProgressBar(for: cell)
		let name = fileNames[indexPath.row]
		updateDownloadIcon(name, cell)
		//Clean up the file name
		let encodedFileName = getEncodedFileName(from: fileNames[indexPath.row])

		if let download = downloads.filter("fileName == %@", encodedFileName).first,
			download.progress != 1 {
			showProgressBar(for: cell, progress: download.progress)

			timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
				if cell.progressBar.progress == 1 {
					timer.invalidate()
					self.hideProgressBar(for: cell)
					self.diskFileNames = Services.getfileNamesFromDisk()
					self.popupTableView.reloadRows(at: [indexPath], with: .automatic)
					return
				}
				cell.progressBar.progress = download.progress
			})
		} else {
			cell.filenameLabel.text = getReadableFileName(from: name)
		}
		return cell
	}

	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		//Configure header view
		header.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
		header.textLabel?.textColor = UIColor.black
		header.textLabel?.textAlignment = .center
		let border = UIView(frame: CGRect(x: 0, y: 39, width: view.frame.width, height: 1))
		border.backgroundColor = UIColor.lightGray

		header.addSubview(border)
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
}

//MARK: - UITableViewDelegate
extension PopUpViewController: UITableViewDelegate {

	fileprivate func openBook(encodedFileName: String) {
		let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(encodedFileName)
		print("File Name: \(encodedFileName)")

		print("File URL: \(fileURL)")
		DownloadManager.shared.docController = UIDocumentInteractionController(url: fileURL)
		let url = URL(string:"itms-books:");
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
		if UIApplication.shared.canOpenURL(url!) {
			DownloadManager.shared.docController.presentOpenInMenu(from: .zero, in: topController.view, animated: true)
			print("iBooks is installed")
		} else {
			// topController should now be your topmost view controller
			Alert.createAlert(topController, title: "iBooks is not installed", message: "\nDownload iBooks from the App Store")
			print("iBooks is not installed")
			}
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! PopUpTableViewCell
		guard let encodedFileName = getEncodedFileName(from: fileNames[indexPath.row]) else {
			print("Cannot encode file name")
			return
		}
		//Open file if it already exists
		if diskFileNames.contains(encodedFileName){
			openBook(encodedFileName: encodedFileName)
			//Download file if it doesn't exist in disk
		} else {
			//Archive.org - download url
			let downloadURL = APISource.archive.downloadURL + bookIdentifier + "/" + fileNames[indexPath.row]
			print("fileURL: - \(downloadURL)")
			//Encoding for whitespace
			let encodedDownloadURL = downloadURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

			showProgressBar(for: cell)

			guard let encodedURL = encodedDownloadURL else {return}

			print("Encoded file name: - \(encodedFileName)")
			DownloadManager().downloadFile(url: encodedURL, fileName: encodedFileName, progressCompletion: { (progress) in
				cell.progressBar.progress = progress
				if let download = DBManager.shared.getDownloads().filter("fileName == %@", encodedFileName).first {
					try! Realm().write {
						download.progress = progress
					}
//					if progress == 1.0 {
//						DBManager.shared.deleteDownload(object: download)
//					}
				}
			}) { (fileURL) in
				Alert.showMessage(theme: .success, title: "Download Complete", body: self.getReadableFileName(from: self.fileNames[indexPath.row]), displayDuration: 5, buttonTitle: "OPEN", completion: {
					self.openBook(encodedFileName: encodedFileName)
				})
				self.hideProgressBar(for: cell)
				//update file names in disk
				self.diskFileNames = Services.getfileNamesFromDisk()
				self.popupTableView.reloadRows(at: [indexPath], with: .automatic)
			}
			//Save book
			let bookIDs = DBManager.shared.getBooks().map{$0.id}
			if !bookIDs.contains(self.book.id) {
				let realmBook = RealmBook(book: self.book)
				//Init book's last opened so as to make it appear in the home screen
				realmBook.lastOpened = Date()
				DBManager.shared.addBook(object: realmBook)
				Alert.showMessage(theme: .warning, title: "Book saved!", body: nil, displayDuration: 1)
			}
		}
		popupTableView.deselectRow(at: indexPath, animated: true)
	}
}
