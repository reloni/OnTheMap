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
	var completion: ((StudentLocation) -> ())!
	var locationTemplate: StudentLocation!
	
	lazy var locationCoordinate: CLLocationCoordinate2D = {
		return CLLocationCoordinate2D(latitude: self.locationTemplate.latitude, longitude: self.locationTemplate.longitude)
	}()
	
	@IBOutlet weak var mapView: MKMapView!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let region = MKCoordinateRegionMakeWithDistance(locationCoordinate, 750, 750);
		let adjustedRegion = mapView.regionThatFits(region)
		mapView.setRegion(adjustedRegion, animated: true)
		
		let annotation = MKPointAnnotation()
		annotation.title = "\(appDelegate.udacityUser?.firstName ?? "") \(appDelegate.udacityUser?.lastName ?? "")"
		annotation.subtitle = locationTemplate.mediaURL
		annotation.coordinate = CLLocationCoordinate2D(latitude: locationTemplate.latitude, longitude: locationTemplate.longitude)
		mapView.addAnnotation(annotation)
	}
	
	@IBAction func finish(_ sender: Any) {
		completion(locationTemplate)
		dismiss(animated: true, completion: nil)
	}
	
}
