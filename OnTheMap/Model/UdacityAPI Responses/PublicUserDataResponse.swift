//
//  PublicUserData.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import Foundation

struct PublicUserDataResponse: Codable {
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
