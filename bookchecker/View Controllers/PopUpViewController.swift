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
	var diskFileNames: [String] = []
	var docController: UIDocumentInteractionController!

	//MARK: - Life Cycle
	override func viewDidLoad() {
        super.viewDidLoad()
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
	fileprivate func showProgressBar(for cell: PopUpTableViewCell) {
		cell.filenameLabel.isHidden = true
		cell.downloadIcon.isHidden = true
		cell.progressBar.progress = 0
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
		return "Select file to open"
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
		cell.filenameLabel.text = getReadableFileName(from: name)

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

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//Archive.org - download url
		let downloadURL = APISource.archive.downloadURL + bookIdentifier + "/" + fileNames[indexPath.row]
		print("fileURL: - \(downloadURL)")
		//Encoding for whitespace
		let encodedDownloadURL = downloadURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

		let cell = tableView.cellForRow(at: indexPath) as! PopUpTableViewCell
		showProgressBar(for: cell)

		guard let encodedURL = encodedDownloadURL else {return}
		guard let encodedFileName = getEncodedFileName(from: fileNames[indexPath.row]) else {
			print("Cannot encode file name")
			return
		}
		print("Encoded file name: - \(encodedFileName)")
		Services.downloadManager().downloadFile(url: encodedURL, fileName: encodedFileName, progressCompletion: { (progress) in
			cell.progressBar.progress = progress
		}) { (fileURL) in
			print(fileURL)
			self.hideProgressBar(for: cell)
			self.diskFileNames = Services.getfileNamesFromDisk()
			self.popupTableView.reloadRows(at: [indexPath], with: .automatic)
			self.docController = UIDocumentInteractionController(url: fileURL)
			let url = URL(string:"itms-books:");
			if UIApplication.shared.canOpenURL(url!) {
			self.docController!.presentOpenInMenu(from: .zero, in: self.view, animated: true)
			print("iBooks is installed")
			} else {
			Alert.createAlert(self, title: "iBooks is not installed", message: "Download iBooks from the App Store")
			print("iBooks is not installed")
			}
		}
	}

}
