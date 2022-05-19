//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import Foundation

struct StudentInformation: Codable {
    
    struct StudentsData: Codable {
        /* YOU DO NOT HAVE TO WORRY ABOUT PARSING DATE OR ACL TYPES. */
        // the date when the student location was created:
        let createdAt: String
        // the first name of the student which matches their Udacity profile first name OR an anonymized name hardcoded in your app (see above)::
        let firstName: String
        // the last name of the student which matches their Udacity profile last name OR an anonymized name hardcoded in your app (see above):
        let lastName: String
        // the latitude of the student location (ranges from -90 to 90)
        let latitude: Double
        // the longitude of the student location (ranges from -180 to 180):
        let longitude: Double
        // the location string used for geocoding the student location:
        let mapString: String
        // the URL provided by the student:
        let mediaURL: String
        // an auto-generated id/key generated by Parse which uniquely identifies a StudentLocation:
        let objectId: String
        // an extra (optional) key used to uniquely identify a StudentLocation; you should populate this value using your Udacity account id:
        let uniqueKey: String
        // the date when the student location was last updated:
        let updatedAt: String
        // the Parse access and control list (ACL), i.e. permissions, for this StudentLocation entry:
        /*
         Define the access level for an entity by placing one of the open, public, internal,
         fileprivate, or private modifiers at the beginning of the entity’s declaration.
         For example, open let ACL, open var ACL, public var ACL, internal let ACL, fileprivate letACL,
         private let ACL.
         */
        //let ACL: String
    }
    
    let results: [StudentsData]
    
}