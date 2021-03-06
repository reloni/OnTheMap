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

extension TableController : LocationDisplayControllerType {
	func refresh() {
		tableView?.reloadSections(IndexSet(integer: 0), with: .automatic)
	}
}

extension TableController : UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return appDelegate.locations.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
		let location = appDelegate.locations[indexPath.row]
		cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
		cell.detailTextLabel?.text = location.mediaURL
		cell.imageView?.image = UIImage(named: "pin")!
		return cell
	}
}

extension TableController : UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let location = appDelegate.locations[indexPath.row]
		guard let url = URL(baseUrl: location.mediaURL) else {
			showErrorAlert(message: "Invalid URL")
			return
		}
		
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
}
