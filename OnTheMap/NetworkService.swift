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
	case incorrectServerResponse
	case unknown
	case jsonParseError(Error)
	case serverSideError([String: Any])
}



enum NetworkRequestResult {
	case success([String: Any])
	case error(Data?, Error, HTTPURLResponse)
	case unknown
}

enum ApiRequestResult {
	case error(Error)
	case authentication(AuthenticationInfo)
	case login(UdacityUser)
	case studentLocations([StudentLocation])
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
	
	private static func parseResponse(isUdacityResponse: Bool = true, responseHandler: @escaping (NetworkRequestResult) -> ()) -> UrlRequestResult {
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
				//let json = try unwrappedData.fromUdacityData().toJson()
				let json: [String: Any] = try {
					if isUdacityResponse { return try unwrappedData.fromUdacityData().toJson() }
					else { return try unwrappedData.toJson() }
				}()
				responseHandler(.success(json))
			} catch let e {
				responseHandler(.error(data, ApplicationErrors.jsonParseError(e), response))
			}
		}
	}
	
	private static func formatCompletionValue(for result: NetworkRequestResult,
	                                          onSuccess: ([String:Any]?) -> ApiRequestResult,
	                                          onError: (Error) -> ApiRequestResult = { .error($0) },
	                                          onUnknown: () -> ApiRequestResult = { .error(ApplicationErrors.unknown) }) -> ApiRequestResult {
		switch result {
		case .success(let json): return onSuccess(json)
		case .error(_, let error, _): return onError(error)
		case .unknown: return onUnknown()
		}
	}
	
	func login(userName: String, password: String, completion: @escaping (ApiRequestResult) -> ()) {
		authenticate(userName: userName, password: password) { [weak self] result in
			guard case ApiRequestResult.authentication(let info) = result else { completion(result); return }
			guard let this = self else { return }
			this.loadUserInfo(auth: info, completion: completion)
		}
	}
	
	func studentLocations(completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.studentLocations()
		networkClient.execute(request, completion: ApiClient.parseResponse(isUdacityResponse: false, responseHandler: { result in
			completion(ApiClient.formatCompletionValue(for: result, onSuccess: { json in
				guard let json = json else { return .error(ApplicationErrors.incorrectServerResponse) }
				guard let results: [Any] = json["results"] as? [Any] else { return .error(ApplicationErrors.incorrectServerResponse) }
				
				let locations = results.filter { $0 is [String: Any] }.map { StudentLocation(json: $0 as! [String:Any]) }.flatMap { $0 }
				return ApiRequestResult.studentLocations(locations)
			}))
		}))
	}
	
	private func authenticate(userName: String, password: String, completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.udacityLogin(userName: userName, password: password)
		
		networkClient.execute(request, completion: ApiClient.parseResponse(responseHandler: { result in
			switch result {
			case .success(let json):
				if let info = AuthenticationInfo(json: json) {
					completion(.authentication(info))
				} else {
					completion(.error(ApplicationErrors.incorrectServerResponse))
				}
			case .error(_, let error, _):
				completion(.error(error))
			case .unknown:
				completion(.error(ApplicationErrors.unknown))
			}
		}))
	}
	
	private func loadUserInfo(auth: AuthenticationInfo, completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.udacityUserInfo(userId: auth.key)
		
		networkClient.execute(request, completion: ApiClient.parseResponse(responseHandler: { result in
			switch result {
			case .success(let json):
				if let user = UdacityUser(authInfo: auth, json: json) {
					completion(.login(user))
				} else {
					completion(.error(ApplicationErrors.incorrectServerResponse))
				}
			case .error(_, let error, _):
				completion(.error(error))
			case .unknown:
				completion(.error(ApplicationErrors.unknown))
			}
		}))
	}
}
