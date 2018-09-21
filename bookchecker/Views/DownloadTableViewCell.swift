//
//  DownloadTableViewCell.swift
//  bookchecker
//
//  Created by Gary on 9/2/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class DownloadTableViewCell: UITableViewCell {
	//MARK: - IBOutlets
	@IBOutlet weak var filenameLabel: UILabel!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var downloadIcon: UIImageView!

	var fileURL: URL?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
