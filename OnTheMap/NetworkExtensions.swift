//
//  NetworkExtensions.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 15.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

extension URLRequest {
	static let udacityLoginUrl = URL(string: "https://www.udacity.com/api/session")!
	static func udacityLogin(userName: String, password: String) -> URLRequest {
		var request = URLRequest(url: URLRequest.udacityLoginUrl)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: ["udacity": ["username":userName, "password": password]], options: [])
		//request.httpBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
		return request
	}
}

extension Data {
	func fromUdacityData() -> Data {
		return Data(dropFirst(5))
	}
	
	func toJson() throws -> JSON {
		return try JSONSerialization.jsonObject(with: self, options: []) as! JSON
	}
	
	func toJsonSafe() -> JSON? {
		return try? toJson()
	}
}
