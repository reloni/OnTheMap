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
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func addAnnototions(_ locations: [StudentLocation]) {
		let annotations = locations.map { loc -> MKPointAnnotation in
			let annotation = MKPointAnnotation()
			annotation.title = "\(loc.firstName) \(loc.lastName)"
			annotation.subtitle = loc.mediaURL
			annotation.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
			return annotation
		}

		DispatchQueue.main.async {
			self.mapView.removeAnnotations(self.mapView.annotations)
			self.mapView.addAnnotations(annotations)
		}
	}
}

extension MapController : LocationDisplayControllerType {
	func refresh() {
		addAnnototions(appDelegate.locations)
	}
}

extension MapController : MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
		
		let pinView: MKPinAnnotationView = {
			guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView else {
				let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
				pin.canShowCallout = true
				pin.animatesDrop = true
				pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
				return pin
			}
			return view
		}()
		
		return pinView
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		guard let subtitle = view.annotation?.subtitle ?? nil else { return }
		guard let url = URL(string: subtitle) else { return }
		
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
}
