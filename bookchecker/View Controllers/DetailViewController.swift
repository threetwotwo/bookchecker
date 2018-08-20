//
//  DetailViewController.swift
//  bookchecker
//
//  Created by Gary on 8/18/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import Cosmos

class DetailViewController: UIViewController {
	//MARK: - IBOutlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var coverImage: UIImageView!
	@IBOutlet weak var publisherLabel: UILabel!
	@IBOutlet weak var publishedDateLabel: UILabel!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var previewButton: UIButton!
	@IBOutlet weak var ratingBar: CosmosView!
	@IBOutlet weak var ratingCountLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var descriptionHeaderLabel: UILabel!

	//MARK: - IBActions
	@IBAction func previewButtonPressed(_ sender: UIButton) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "WebReaderVC") as! WebReaderViewController
		guard let previewURL = URL(string: book.previewLink.replacingOccurrences(of: "gbs_api", with: "kp_read_button")) else {
			return
		}
		vc.previewLink = previewURL
		vc.previewLink.setValue(forKey: "pg", to: "PA1")
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//MARK: - variables
	var book: Book!

	//MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

	override func viewWillAppear(_ animated: Bool) {
		updateUI()
	}

	//MARK: - Update UI
	func updateUI() {
		print(book)
		titleLabel.text = book.title
		authorLabel.text = book.authors
		publisherLabel.text = book.publisher == "" ? "Unknown Publisher" : book.publisher
		publishedDateLabel.text = book.publishedDate
		categoryLabel.text = book.categories

		if book.ratingsCount == "" {
			ratingBar.isHidden = true
			ratingCountLabel.isHidden = true
		} else {
			ratingBar.rating = Double(book.averageRating) ?? 0
			ratingCountLabel.text = "(\(book.ratingsCount))"
		}

		descriptionHeaderLabel.text = book.about == "" ? "No description" : "Description"

		descriptionLabel.text = book.about
		categoryLabel.text =  book.categories

		Services.shared.getBookImage(from: book.thumbnail) { (image) in
			self.coverImage.image = image
		}
	}
}
