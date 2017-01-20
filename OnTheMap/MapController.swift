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
		
		apiClient.studentLocations { result in
				print(result)
		}
	}
}
