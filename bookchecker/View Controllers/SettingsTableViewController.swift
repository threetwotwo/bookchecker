//
//  SettingsTableViewController.swift
//  bookchecker
//
//  Created by Gary on 9/25/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
	//MARK: - IBOutlets
	@IBOutlet weak var matureSwitch: UISwitch!
	let defaults = UserDefaults.standard

	//MARK: - IBActions
	@IBAction func matureSwitched(_ sender: UISwitch) {
		defaults.set(sender.isOn, forKey: "matureContent")
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		let matureSetting = defaults.bool(forKey: "matureContent")
		matureSwitch.setOn(matureSetting, animated: false)
    }
}
