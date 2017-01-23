//
//  TableController.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 15.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

final class TableController : UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
}

extension TableController : UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return appDelegate.locations.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
		let location = appDelegate.locations[indexPath.row]
		cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
		cell.imageView?.image = UIImage(named: "pin")!
		return cell
	}
}

extension TableController : UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let location = appDelegate.locations[indexPath.row]
		guard let url = URL(string: location.mediaURL) else { return }
		
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
}
