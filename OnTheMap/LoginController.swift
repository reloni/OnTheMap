//
//  LoginController.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 15.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
	@IBOutlet weak var loginTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func logInTap(_ sender: Any) {
		guard let login = loginTextField.text, login.characters.count > 0 else { return }
		guard let password = passwordTextField.text, password.characters.count > 0 else { return }
		
		apiClient.login(userName: login, password: password) { result in
			switch result{
			case .login(let user): print(user)
			case .error(let e): print(e)
			default: break
			}
		}
	}
}

