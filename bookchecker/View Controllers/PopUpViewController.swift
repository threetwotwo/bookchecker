//
//  PopUpViewController.swift
//  bookchecker
//
//  Created by Gary on 9/1/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var popupTableView: UITableView! {
		didSet {
			popupTableView.reloadData()
		}
	}
	@IBOutlet weak var heightConstraint: NSLayoutConstraint!

	//MARK: - IBActions
	@IBAction func closePopUp(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	//MARK: - Variables
	var bookTitle: String?
	var fileNames: [String]!

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

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpCell", for: indexPath)
		cell.textLabel?.text = fileNames[indexPath.row]
		return cell
	}


}

//MARK: - UITableViewDelegate
extension PopUpViewController: UITableViewDelegate {

}
