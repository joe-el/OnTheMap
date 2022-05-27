//
//  ErrorResponse.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/15/22.
//

import Foundation

struct ErrorResponse: Codable {
    let status: Int
    let error: String
}

// Conform to localized error, now we can provide an error message that's more readable:
extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
