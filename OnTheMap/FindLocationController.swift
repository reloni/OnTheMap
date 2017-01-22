//
//  FindLocationController.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 22.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit
import MapKit

final class FindLocationController : UIViewController {
	var completion: ((CLLocationCoordinate2D, URL) -> ())?
	
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var webSiteTextField: UITextField!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func findLocation(_ sender: Any) {
		guard let geoString = locationTextField.text, geoString.characters.count > 0 else {
			showErrorAlert(message: "Must enter a location")
			return
		}
		
		guard let urlString = webSiteTextField.text, let url = URL(string: urlString) else {
			showErrorAlert(message: "Must enter a valid URL")
			return
		}
		
		loadGeoCoordinates(for: geoString) { result in
			guard let result = result else {
				self.showErrorAlert(message: "Unable to find a location")
				return
			}
			
			DispatchQueue.main.async {
				let controller = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmLocationController") as! ConfirmLocationController
				controller.completion = self.completion
				controller.location = result
				controller.url = url
				self.navigationController?.pushViewController(controller, animated: true)
			}
		}
	}
	
	@IBAction func cancel(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}
