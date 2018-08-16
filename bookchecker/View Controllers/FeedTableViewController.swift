//
//  FeedTableViewController.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FeedTableViewController: UITableViewController {

	let queries = [
		"potter",
		"mommy",
		"john",
		"dumpster",
		"bear",
		"dota",
		"competition",
		"hiking",
		"gentle",
		"rough"
	]

    override func viewDidLoad() {
        super.viewDidLoad()
    }


	//MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		return queries.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return queries[section]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
		cell.genre = queries[indexPath.row]
		return cell
	}

}
