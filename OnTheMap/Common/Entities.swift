//
//  Entities.swift
//  OnTheMap
//
//  Created by Anton Efimenko on 19.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

struct AuthenticationInfo {
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

struct UdacityUser {
	let authenticationInfo: AuthenticationInfo
	let firstName: String
	let lastName: String
	
	init?(authInfo: AuthenticationInfo, json: [String: Any]) {
		guard let fn: String = json[jsonKey: "user"]?["first_name"] as? String else { return nil }
		guard let ln: String = json[jsonKey: "user"]?["last_name"] as? String else { return nil }
		
		authenticationInfo = authInfo
		firstName = fn
		lastName = ln
	}
}

struct StudentLocation {
	let firstName: String
	let lastName: String
	let latitude: Double
	let longitude: Double
	let mapString: String
	let mediaURL: String
	let objectId: String
	let uniqueKey: String
	
	init?(json: [String:Any]) {
		guard let fn: String = json["firstName"] as? String else { return nil }
		guard let ln: String = json["lastName"] as? String else { return nil }
		guard let ms: String = json["mapString"] as? String else { return nil }
		guard let mu: String = json["mediaURL"] as? String else { return nil }
		guard let oi: String = json["objectId"] as? String else { return nil }
		guard let uk: String = json["uniqueKey"] as? String else { return nil }
		guard let lo: Double = json["longitude"] as? Double else { return nil }
		guard let la: Double = json["latitude"] as? Double else { return nil }
		
		firstName = fn
		lastName = ln
		latitude = la
		longitude = lo
		mapString = ms
		mediaURL = mu
		objectId = oi
		uniqueKey = uk
	}
}
