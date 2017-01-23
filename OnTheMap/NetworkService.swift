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

/// Represents response from network
enum NetworkRequestResult {
	case success([String: Any])
	case error(Data?, Error, HTTPURLResponse)
	case unknown
}

/// Represents API call result
enum ApiRequestResult {
	/// Error occurred
	case error(Error)
	/// User successfully authenticated
	case authentication(AuthenticationInfo)
	/// User login completed
	case login(UdacityUser)
	/// Locations loaded
	case studentLocations([StudentLocation])
	/// User signed out
	case logoff
	case currentUserLocation(StudentLocation?)
}

final class NetworkClient {
	let session: URLSession
	
	init(session: URLSession = URLSession(configuration: .default)) {
		self.session = session
	}
	
	/// Executes URL request
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
			guard let response = response as? HTTPURLResponse else { responseHandler(.unknown); return }
			
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
	                                          onSuccess: ([String:Any]) -> ApiRequestResult,
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
	
	func logoff(completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.udacityLogoff()
		networkClient.execute(request, completion: ApiClient.parseResponse(responseHandler: { result in
			completion(ApiClient.formatCompletionValue(for: result, onSuccess: { _ in .logoff }))
		}))
	}
	
	func currentUserLocation(userUniqueKey: String, completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.userLocation(uniqueKey: userUniqueKey)
		networkClient.execute(request, completion: ApiClient.parseResponse(isUdacityResponse: false, responseHandler: { result in
			completion(ApiClient.formatCompletionValue(for: result, onSuccess: { json in
				guard let locationJson = (json["results"] as? [Any])?.first as? [String:Any] else { return .currentUserLocation(nil) }
				return .currentUserLocation(StudentLocation(json: locationJson))
			}))
		}))
	}
	
	func studentLocations(completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.studentLocations()
		networkClient.execute(request, completion: ApiClient.parseResponse(isUdacityResponse: false, responseHandler: { result in
			completion(ApiClient.formatCompletionValue(for: result, onSuccess: { json in
				guard let results: [Any] = json["results"] as? [Any] else { return .error(ApplicationErrors.incorrectServerResponse) }
				
				let locations = results.filter { $0 is [String: Any] }.map { StudentLocation(json: $0 as! [String:Any]) }.flatMap { $0 }
				return ApiRequestResult.studentLocations(locations)
			}))
		}))
	}
	
	private func authenticate(userName: String, password: String, completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.udacityLogin(userName: userName, password: password)
		
		networkClient.execute(request, completion: ApiClient.parseResponse(responseHandler: { result in
			completion(ApiClient.formatCompletionValue(for: result, onSuccess: { json in
				if let info = AuthenticationInfo(json: json) {
					return .authentication(info)
				} else {
					return .error(ApplicationErrors.incorrectServerResponse)
				}
			}))
		}))
	}
	
	private func loadUserInfo(auth: AuthenticationInfo, completion: @escaping (ApiRequestResult) -> ()) {
		let request = URLRequest.udacityUserInfo(userId: auth.key)
		
		networkClient.execute(request, completion: ApiClient.parseResponse(responseHandler: { result in
			completion(ApiClient.formatCompletionValue(for: result, onSuccess: { json in
				if let user = UdacityUser(authInfo: auth, json: json) {
					return .login(user)
				} else {
					return .error(ApplicationErrors.incorrectServerResponse)
				}
			}))
		}))
	}
}
