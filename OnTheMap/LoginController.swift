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
	@IBOutlet weak var signUpLabel: UILabel!
	
	var editingTextField: UITextField?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(signUp))
		recognizer.numberOfTapsRequired = 1
		signUpLabel.isUserInteractionEnabled = true
		signUpLabel.addGestureRecognizer(recognizer)
		
		loginTextField.delegate = self
		passwordTextField.delegate = self
		
		let kc = Keychain()
		if let userName = kc.stringForAccount(account: "UserName") {
			loginTextField.text = userName
		}
		
		if let userPassword = kc.stringForAccount(account: "Password") {
			passwordTextField.text = userPassword
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}
	
	func signUp() {
		UIApplication.shared.open(URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!,
		                          options: [:],
		                          completionHandler: nil)
	}
	
	func keyboardWillShow(_ notification: Notification) {
		guard let textField = editingTextField else { return }
		
		let fieldYPosition = view.frame.height - (textField.frame.origin.y + textField.frame.height)
		let keyboardHeight = notification.keyboardHeight()
		
		// adjust frame only if keyboard hides text field
		guard keyboardHeight > fieldYPosition else {
			return
		}
		
		UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut, animations: {
			self.view.frame.origin.y = fieldYPosition - keyboardHeight - 10
		})
	}
	
	func keyboardWillHide(_ notification: Notification) {
		UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut, animations: {
			self.view.frame.origin.y = 0
		})
	}
	
	@IBAction func logInTap(_ sender: Any) {
		guard let login = loginTextField.text, login.characters.count > 0 else { return }
		guard let password = passwordTextField.text, password.characters.count > 0 else { return }
		
		let activity = createActivityView()
		view.addSubview(activity)
		
		apiClient.login(userName: login, password: password) { [weak self] result in
			activity.safeRomoveFromSuperview()
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


extension LoginController : UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		editingTextField = textField
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

