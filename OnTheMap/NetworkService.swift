//
//  NetworkService.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 15.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

typealias UrlRequestResult = (Data?, URLResponse?, Error?) -> ()

enum ApplicationErrors : Error {
	case incorrectUserData
	case unknown
	case jsonParseError(Error)
	case serverSideError([String: Any])
}

struct LoggedUser {
	let registered: Bool
	let key: String
	let sessionId: String
	
	init?(json: [String: Any]) {
		guard let reg: Bool = json[jsonKey: "account"]?["registered"] as? Bool else { return nil }
		guard let key: String = json[jsonKey: "account"]?["key"] as? String else { return nil }
		guard let id: String = json[jsonKey: "session"]?["id"] as? String else { return nil }
		
		self.registered = reg
		self.key = key
		self.sessionId = id
	}
}

enum NetworkRequestResult {
	case success([String: Any])
	case error(Data?, Error, HTTPURLResponse)
	case unknown
}

enum ApiRequestResult {
	case error(Error)
	case logIn(LoggedUser)
}

final class NetworkClient {
	let session: URLSession
	
	init(session: URLSession = URLSession(configuration: .default)) {
		self.session = session
	}
	
	func execute(_ request: URLRequest, completion: @escaping UrlRequestResult) {
		print("Execute url: \(request.url?.absoluteString ?? "")")
		session.dataTask(with: request, completionHandler: completion).resume()
	}
}

final class ApiClient {
	let networkClient: NetworkClient
	init(networkClient: NetworkClient = NetworkClient()) {
		self.networkClient = networkClient
	}
	
	private func parseResponse(responseHandler: @escaping (NetworkRequestResult) -> ()) -> UrlRequestResult {
		return { data, response, error in
			let response = response as! HTTPURLResponse
			
			guard 200...299 ~= response.statusCode else {
				if let serverResponse = data?.fromUdacityData().toJsonSafe() {
					responseHandler(.error(data, ApplicationErrors.serverSideError(serverResponse), response))
				} else {
					responseHandler(.error(data, error ?? ApplicationErrors.unknown, response))
				}
				return
			}
			
			guard let unwrappedData = data else {
				guard let error = error else { responseHandler(.unknown); return }
				responseHandler(.error(data, error, response))
				return
			}
			
			do {
				let json = try unwrappedData.fromUdacityData().toJson()
				responseHandler(.success(json))
			} catch let e {
				responseHandler(.error(data, ApplicationErrors.jsonParseError(e), response))
			}
		}
	}
	
	func login(userName: String, password: String, completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.udacityLogin(userName: userName, password: password)
		
		networkClient.execute(request, completion: parseResponse(responseHandler: { result in
			switch result {
			case .success(let json):
				if let user = LoggedUser(json: json) {
					completion(.logIn(user))
				} else {
					completion(.error(ApplicationErrors.incorrectUserData))
				}
			case .error(_, let error, _):
				completion(.error(error))
			case .unknown:
				completion(.error(ApplicationErrors.unknown))
			}
		}))
	}
}
