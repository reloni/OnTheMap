//
//  NetworkService.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 15.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

typealias JSON = Dictionary<String, Any>
typealias UrlRequestResult = (Data?, URLResponse?, Error?) -> ()

enum NetworkRequestResult {
	case success(JSON)
	case error(Data?, Error?, HTTPURLResponse)
	case unknown
	case jsonParseError(Error)
}

final class NetworkService {
	let session: URLSession
	
	init(session: URLSession = URLSession(configuration: .default)) {
		self.session = session
	}
	
	func execute(_ request: URLRequest, completion: @escaping UrlRequestResult) {
		print("Execute url: \(request.url?.absoluteString ?? "")")
		session.dataTask(with: request, completionHandler: completion).resume()
	}
	
	func parseResponse(responseHandler: @escaping (NetworkRequestResult) -> ()) -> UrlRequestResult {
		return { data, response, error in
			let response = response as! HTTPURLResponse
			
			guard 200...299 ~= response.statusCode else {
				responseHandler(.error(data, error, response))
				return
			}
			
			guard let unwrappedData = data else {
				guard let error = error else { responseHandler(.unknown); return }
				responseHandler(.error(data, error, response))
				return
			}
			
			do {
				//print(NSString(data: unwrappedData.fromUdacityData(), encoding: String.Encoding.utf8.rawValue))
				let json = try unwrappedData.fromUdacityData().toJson()
				responseHandler(.success(json))
			} catch let e {
				responseHandler(.jsonParseError(e))
			}
		}
	}
	
	func login(userName: String, password: String, completion: @escaping (NetworkRequestResult) -> ()) {
		let request = URLRequest.udacityLogin(userName: userName, password: password)
		execute(request, completion: parseResponse(responseHandler: completion))
	}
}
