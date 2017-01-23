//
//  ConfirmLocationController.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 22.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit
import MapKit

final class ConfirmLocationController : UIViewController {
	var completion: ((CLLocationCoordinate2D, URL) -> ())!
	var location: CLLocationCoordinate2D!
	var url: URL!
	
	@IBOutlet weak var mapView: MKMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let region = MKCoordinateRegionMakeWithDistance(location, 750, 750);
		let adjustedRegion = mapView.regionThatFits(region)
		mapView.setRegion(adjustedRegion, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let annotation = MKPointAnnotation()
		annotation.title = "\(appDelegate.udacityUser?.firstName ?? "") \(appDelegate.udacityUser?.lastName ?? "")"
		annotation.subtitle = url.absoluteString
		annotation.coordinate = location
		mapView.addAnnotation(annotation)
	}
	
	@IBAction func finish(_ sender: Any) {
		completion(location, url)
		dismiss(animated: true, completion: nil)
	}
	
}
