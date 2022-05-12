//
//  DeleteResponse.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import Foundation

struct DeleteResponse: Codable {
    struct Session: Codable {
        let id: String
        let expiration: String
    }
    
    let session: Session
}
