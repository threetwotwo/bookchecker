//
//  TestTableViewController.swift
//  bookchecker
//
//  Created by Gary on 8/14/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {

	var items: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

		for i in 1...1000 {
			items.append("\(i)")
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath)
		cell.textLabel?.text = items[indexPath.row]
		return cell
	}

}
