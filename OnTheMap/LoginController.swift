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
		
		let kc = Keychain()
		if let userName = kc.stringForAccount(account: "UserName") {
			loginTextField.text = userName
		}
		
		if let userPassword = kc.stringForAccount(account: "Password") {
			passwordTextField.text = userPassword
		}
	}
	
	@IBAction func logInTap(_ sender: Any) {
		guard let login = loginTextField.text, login.characters.count > 0 else { return }
		guard let password = passwordTextField.text, password.characters.count > 0 else { return }
		
		apiClient.login(userName: login, password: password) { [weak self] result in
			switch result{
			case .login(let user):
				self?.appDelegate.udacityUser = user
				self?.saveInKeychain(userName: login, password: password)
				self?.presentRootController()
				DispatchQueue.main.async { self?.passwordTextField.text = nil }
			case .error(let e): self?.showErrorAlert(error: e)
			default: break
			}
		}
	}
	
	func saveInKeychain(userName: String, password: String) {
		let kc = Keychain()
		kc.setString(string: userName, forAccount: "UserName", synchronizable: true, background: false)
		kc.setString(string: password, forAccount: "Password", synchronizable: true, background: false)
	}
}

