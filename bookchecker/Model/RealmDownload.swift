//
//  RealmDownload.swift
//  bookchecker
//
//  Created by Gary on 9/19/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDownload: Object {
	@objc dynamic var fileName = ""
	@objc dynamic var progress: Float = 0
	@objc dynamic var resumeData: Data? = nil
}
