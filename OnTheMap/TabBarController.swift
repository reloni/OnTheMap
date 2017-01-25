//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 19.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

protocol LocationDisplayControllerType {
	func refresh()
}

final class TabBarController : UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshTabs()
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
		refreshTabs()
	}
	
	@IBAction func addUserLocation(_ sender: Any) {
		apiClient.currentUserLocation(userUniqueKey: appDelegate.udacityUser!.authenticationInfo.key) { [weak self] result in
				switch result {
				case ApiRequestResult.currentUserLocation(let currentLocation):
					self?.presentFindLocatonController(currentLocation: currentLocation) { result in
						if currentLocation == nil {
							self?.createStudentLocation(template: result) { error in
								guard let error = error else { self?.refreshTabs(); return }
								self?.showErrorAlert(error: error)
							}
						} else {
							self?.updateUserLocation(currentLocationId: currentLocation!.objectId, template: result) { error in
								guard let error = error else { self?.refreshTabs(); return }
								self?.showErrorAlert(error: error)
							}
						}
					}
				case .error(let e): self?.showErrorAlert(error: e)
				default: break
			}
		}
	}
	
	func refreshTabs() {
		apiClient.studentLocations { [weak self] result in
			switch result {
			case ApiRequestResult.studentLocations(let locations):
				guard let this = self else { return }
				this.appDelegate.locations = locations
				for tab in this.viewControllers! {
					DispatchQueue.main.async { (tab as? LocationDisplayControllerType)?.refresh() }
				}
			case .error(let e): self?.showErrorAlert(error: e)
			default: break
			}
		}
	}
	
	func createStudentLocation(template: StudentLocation, completion: @escaping (Error?) -> ()) {
		apiClient.createStudentLocation(template) { result in
			switch result {
			case .locationCreated: completion(nil)
			case .error(let e): completion(e)
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
