//
//  MapController.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 15.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import MapKit
import UIKit

final class MapController : UIViewController {
	@IBOutlet weak var mapView: MKMapView!
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		apiClient.studentLocations { [weak self] result in
			switch result {
			case ApiRequestResult.studentLocations(let locations): self?.addAnnototions(locations)
			case .error(let e): self?.showErrorAlert(error: e)
			default: break
			}
			
		}
	}
	
	func addAnnototions(_ locations: [StudentLocation]) {
		let annotations = locations.map { loc -> MKPointAnnotation in
			let annotation = MKPointAnnotation()
			annotation.title = loc.mapString
			annotation.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
			return annotation
		}

		mapView.addAnnotations(annotations)
	}
}
