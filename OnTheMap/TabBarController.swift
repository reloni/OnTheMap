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
		//navigationItem.leftBarButtonItem?.title = "LOGOUT"
		//UIBarButtonItem(title: "", style: ., target: <#T##Any?#>, action: <#T##Selector?#>)
	}
	
	@IBAction func logOut(_ sender: Any) {
		appDelegate.udacityUser = nil
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func refresh(_ sender: Any) {
		print("refresh")
	}
	
}
