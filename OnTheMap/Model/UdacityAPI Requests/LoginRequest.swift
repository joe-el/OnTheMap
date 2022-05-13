//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import Foundation

struct LoginRequest: Codable {
    
    struct AuthPair: Codable {
        // the username (email) for a Udacity student:
        let username: String
        // the password for a Udacity student:
        let password: String
    }
    
    // a dictionary containing a username/password pair used for authentication:
    let udacity: AuthPair
    
}
