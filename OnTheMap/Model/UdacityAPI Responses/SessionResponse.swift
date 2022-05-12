//
//  SessionResponse.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import Foundation

struct SessionResponse: Codable {
    
    struct Account: Codable {
        let registered: Bool
        let key: String
    }
    struct Session: Codable {
        let id: String
        let expiration: String
    }
    
    let account: Account
    let session: Session
    
}
