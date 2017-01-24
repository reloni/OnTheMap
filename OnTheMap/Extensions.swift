//
//  Extensions.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 17.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension Dictionary {
	subscript(jsonKey key: Key) -> [String:Any]? {
		return self[key] as? [String:Any]
	}
}

extension URL {
	init?(baseUrl: String, parameters: [String: String]? = nil) {
		var components = URLComponents(string: baseUrl)
		components?.queryItems = parameters?.map { key, value in
			URLQueryItem(name: key, value: value)
		}
		
		guard let absoluteString = components?.url?.absoluteString else { return nil }
		
		self.init(string: absoluteString)
	}
}

extension URLRequest {
	static func udacityLogin(userName: String, password: String) -> URLRequest {
		var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: ["udacity": ["username":userName, "password": password]], options: [])
		return request
	}
	
	static func udacityLogoff() -> URLRequest {
		var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
		request.httpMethod = "DELETE"

		if let xsrfCookie = { HTTPCookieStorage.shared.cookies?.filter { $0.name == "XSRF-TOKEN" }.first }() {
			request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
		}

		return request
	}
	
	static func udacityUserInfo(userId id: String) -> URLRequest {
		return URLRequest(url: URL(string: "https://www.udacity.com/api/users")!.appendingPathComponent(id))
	}
	
	static func studentLocations() -> URLRequest {
		var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
		request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
		return request
	}
	
	static func userLocation(uniqueKey: String) -> URLRequest {
		var request = URLRequest(url: URL(baseUrl: "https://parse.udacity.com/parse/classes/StudentLocation",
		                                  parameters: ["where": "{\"uniqueKey\":\"\(uniqueKey)\"}"])!)
		
		request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
		return request
	}
	
	static func createLocation(with locationJson: [String:Any]) -> URLRequest {
		var request = URLRequest(url: URL(baseUrl: "https://parse.udacity.com/parse/classes/StudentLocation")!)
		
		request.httpMethod = "POST"
		
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
		
		request.httpBody = try? JSONSerialization.data(withJSONObject: locationJson, options: [])
		
		return request
	}
	
	static func updateLocation(forLocationId: String, with locationJson: [String:Any]) -> URLRequest {
		var request = URLRequest(url: URL(baseUrl: "https://parse.udacity.com/parse/classes/StudentLocation/\(forLocationId)")!)
		
		request.httpMethod = "PUT"
		
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
		
		request.httpBody = try? JSONSerialization.data(withJSONObject: locationJson, options: [])
		
		return request
	}
}

extension Data {
	func fromUdacityData() -> Data {
		return Data(dropFirst(5))
	}
	
	func toJson() throws -> [String: Any] {
		return try JSONSerialization.jsonObject(with: self, options: []) as! [String: Any]
	}
	
	func toJsonSafe() -> [String: Any]? {
		return try? toJson()
	}
}

extension UIViewController {
	func loadGeoCoordinates(for geoString : String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
		CLGeocoder().geocodeAddressString(geoString) { (marks, error) in
			guard error == nil else { completion(nil); return }
			completion(marks?.last?.location?.coordinate)
		}
	}
	
	var appDelegate: AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}
	
	func showErrorAlert(error: Error) {
		let errorMessage: String = {
			switch error {
			case ApplicationErrors.incorrectServerResponse: return "Incorrect response from server"
			case ApplicationErrors.jsonParseError(let e): return e.localizedDescription
			case ApplicationErrors.serverSideError(let json): return (json["error"] as? String) ?? "Unknown error"
			default: return error.localizedDescription
			}
		}()
		
		showErrorAlert(message: errorMessage)
	}
	
	func showErrorAlert(message: String) {
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		
		DispatchQueue.main.async {
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func presentRootController() {
		DispatchQueue.main.async {
			let controller = self.storyboard!.instantiateViewController(withIdentifier: "RootNavigationController")
			self.present(controller, animated: true, completion: nil)
		}
	}
	
	func presentFindLocatonController(currentLocation: StudentLocation?, completion: @escaping (StudentLocation) -> ()) {
		if currentLocation != nil {
			// show alert
			print("Current location exists: \(currentLocation != nil)")
		}
		
		DispatchQueue.main.async {
			let controller = self.storyboard!.instantiateViewController(withIdentifier: "FindLocationNavigationController") as! UINavigationController
			(controller.topViewController as! FindLocationController).completion = completion
			self.present(controller, animated: true, completion: nil)
		}
	}
}
