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
