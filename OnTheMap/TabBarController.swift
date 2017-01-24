//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 19.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

final class TabBarController : UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func logOut(_ sender: Any) {
		appDelegate.udacityUser = nil
		apiClient.logoff { [weak self] result in
			if case ApiRequestResult.error = result {
				self?.showErrorAlert(message: "Error while logging off")
			}
			
			DispatchQueue.main.async {
				// remove user password from keychain
				let kc = Keychain()
				kc.setString(string: nil, forAccount: "Password", synchronizable: true, background: false)
				self?.dismiss(animated: true, completion: nil)
			}
		}
		
	}
	
	@IBAction func refresh(_ sender: Any) {
		print("refresh. Cur index: \(selectedIndex)")
		
	}
	
	@IBAction func addUserLocation(_ sender: Any) {
		apiClient.currentUserLocation(userUniqueKey: appDelegate.udacityUser!.authenticationInfo.key) { [weak self] result in
				switch result {
				case ApiRequestResult.currentUserLocation(let currentLocation):
					self?.presentFindLocatonController(currentLocation: currentLocation) { result in
						print("New location: \(result)")
						if currentLocation == nil {
							print("create new location")
						} else {
							print("update current location")
							self?.updateUserLocation(currentLocationId: currentLocation!.objectId, template: result) { error in
									print("update error: \(error)")
							}
						}
					}
				case .error(let e): self?.showErrorAlert(error: e)
				default: break
			}
		}
	}
	
	func updateUserLocation(currentLocationId: String, template: StudentLocation, completion: @escaping (Error?) -> ()) {
		apiClient.updateLocation(locationId: currentLocationId, newLocation: template) { result in
			switch result {
			case .locationUpdated: completion(nil)
			case .error(let e): completion(e)
			default: break
			}
		}
	}
}
