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
}
