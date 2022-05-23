//
//  AddUserRequest.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/22/22.
//

import Foundation

// Posting user information:
struct AddUserRequest {
    
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    init() {
        uniqueKey = ""
        firstName = "Ken"
        lastName = "Gutierrez"
        mapString = ""
        mediaURL = ""
        latitude = 0.0
        longitude = 0.0
    }
    
}
