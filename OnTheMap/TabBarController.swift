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
		print("refresh")
	}
	
}
