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

	@IBAction func logInTap(_ sender: Any) {
//		presentRootController()
//		return
		
		guard let login = loginTextField.text, login.characters.count > 0 else { return }
		guard let password = passwordTextField.text, password.characters.count > 0 else { return }
		
		apiClient.login(userName: login, password: password) { [weak self] result in
			switch result{
			case .login(let user):
				self?.appDelegate.udacityUser = user
				self?.presentRootController()
			case .error(let e): self?.showErrorAlert(error: e)
			default: break
			}
		}
	}
}

