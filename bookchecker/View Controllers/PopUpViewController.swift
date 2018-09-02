//
//  PopUpViewController.swift
//  bookchecker
//
//  Created by Gary on 9/1/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import Alamofire

class PopUpViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var popupTableView: UITableView!
	@IBOutlet weak var heightConstraint: NSLayoutConstraint!

	//MARK: - IBActions
	@IBAction func closePopUp(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	//MARK: - Variables
	var bookIdentifier: String!
	var bookTitle: String?
	var fileNames: [String]!
	var docController: UIDocumentInteractionController!

	//MARK: - Life Cycle
	override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewDidLayoutSubviews() {
		//table view content + button height
		let contentHeight = popupTableView.contentSize.height + 30
		//set pop up view maximum height to 400
		heightConstraint.constant = min(contentHeight, 400)
	}
}

//MARK: - UITableViewDataSource
extension PopUpViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return bookTitle
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fileNames.count
	}

	fileprivate func setReadableFileName(at indexPath: IndexPath, _ cell: PopUpTableViewCell) {
		let name = fileNames[indexPath.row]
		if let index = (name.range(of: ".")?.upperBound), name.countInstances(of: ".") > 1, name.countInstances(of: "-") == 0 {
			cell.filenameLabel.text = String(name.suffix(from: index))
		} else if let index = (name.range(of: "-")?.upperBound){
			cell.filenameLabel.text = String(name.suffix(from: index))
		} else {
			cell.filenameLabel.text = name
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpCell", for: indexPath) as! PopUpTableViewCell
		setReadableFileName(at: indexPath, cell)
		return cell
	}


}

//MARK: - UITableViewDelegate
extension PopUpViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
		let fileURL = APISource.archive.downloadURL + bookIdentifier + "/" + fileNames[indexPath.row]
		print("fileURL: - \(fileURL)")
		//Replace whitespace
		let encodedFileURL = fileURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		print(encodedFileURL)
		Alamofire.download(encodedFileURL!, to: destination).response { (response) in
			if let error = response.error {
				print("Failed with error: \(error)")
			} else {
				print("Downloaded file successfully")
			}
			if let targetURL = response.destinationURL {
				self.docController = UIDocumentInteractionController(url: targetURL)
				let url = URL(string:"itms-books:");
				if UIApplication.shared.canOpenURL(url!) {
					self.docController!.presentOpenInMenu(from: .zero, in: self.view, animated: true)
					print("iBooks is installed")
				} else {
					print("iBooks is not installed")
				}
			}
		}
	}
}
