//
//  UdacityAPIClient.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import MapKit

class UdacityAPIClient {
    
    // MARK: - Authentication Properties
    struct Auth {
        static var userId = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
        static var sessionId = ""
        static var pinAlreadyPosted = false
    }

    // MARK: - Udacity API URL's
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        static let studentLocationPath = "/StudentLocation"
        static let sessionPath = "/session"
        static let userIdPath = "/users"
        
        case studentLocation
        case limit(Int)
        case skip(Int, Int)
        case order(limit: Int, sorted:String)
        case uniqueKey
        case objectId
        case sessionId
        case publicUserData
        case signUp
        
        var stringValue: String {
            switch self {
            case .studentLocation:
                return Endpoints.base + Endpoints.studentLocationPath
            // specifies the maximum number of StudentLocation objects to return in the JSON response:
            case .limit(let maxToReturn):
                return Endpoints.base + Endpoints.studentLocationPath + "?limit=\(maxToReturn)"
            // use this parameter with limit to paginate through results:
            case .skip(let maxToReturn, let limitPaginate):
                return Endpoints.base + Endpoints.studentLocationPath + "?limit=\(maxToReturn)" + "&skip=\(limitPaginate)"
            /*
             a comma-separate list of key names that specify the sorted order of the results:
             Prefixing a key name with a negative sign reverses the order (default order is ascending)
             such as -updatedAt:
             */
            case .order(let maxToReturn, let keyName):
                return Endpoints.base + Endpoints.studentLocationPath + "?limit=\(maxToReturn)" + "&order=\(keyName)"
            // a unique key (user ID). Gets only student locations with a given user ID:
            case .uniqueKey:
                return Endpoints.base + Endpoints.studentLocationPath + "?uniqueKey=\(Auth.userId)"
            // the object ID of the StudentLocation to update:
            case .objectId:
                return Endpoints.base + Endpoints.studentLocationPath + "/\(Auth.objectId)"
            case .sessionId:
                return Endpoints.base + Endpoints.sessionPath
            case .publicUserData:
                return Endpoints.base + Endpoints.userIdPath + "/\(Auth.userId)"
            case .signUp:
                return "https://auth.udacity.com/sign-up"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - GETing multiple student locations at one time:
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, getPublicUserData: Bool, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
           
            let decoder = JSONDecoder()
            do {
                if getPublicUserData {
                    let range = 5..<data.count
                    let newData = data.subdata(in: range) /* subset response data! */
                    let responseObject = try decoder.decode(responseType.self, from: newData)
                    DispatchQueue.main.async {
                        completionHandler(responseObject, nil)
                    }
                } else {
                    let responseObject = try decoder.decode(responseType.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(responseObject, nil)
                    }
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        task.resume()
    }

    // MARK: - POSTing a new student location and a session:
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, getSessionId: Bool, body: RequestType, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        if getSessionId {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { // Handle error…
                DispatchQueue.main.async {
                    // Need to create custom error message for timeout error... failed network connection:
                    completionHandler(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                if getSessionId {
                    let range = 5..<data.count
                    let newData = data.subdata(in: range) /* subset response data! */
                    let responseObject = try decoder.decode(responseType.self, from: newData)
                    DispatchQueue.main.async {
                        completionHandler(responseObject, nil)
                    }
                } else {
                    let responseObject = try decoder.decode(responseType.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(responseObject, nil)
                    }
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        task.resume()
    }

    // MARK: - PUTing a student location by update an existing student location:
    class func taskForPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }

    // MARK: - DELETEing a session
    class func taskForDELETERequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else { // Handle error…
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            
            let decoder = JSONDecoder()
            do {
                let respondObject = try decoder.decode(responseType.self, from: newData)
                DispatchQueue.main.async {
                    completionHandler(respondObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - GETting Public User Data
    // retrieve some basic user information before posting data to Parse(Udacity):
    class func getPulicUserData(completionHandler: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.publicUserData.url, getPublicUserData: true, responseType: PublicUserDataResponse.self) { (response, error) in
            if let response = response {
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    // MARK: - Requests
    class func login(username: String, password: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: LoginRequest.AuthPair(username: username, password: password))
        
        taskForPOSTRequest(url: Endpoints.sessionId.url, getSessionId: true, body: body, responseType: SessionResponse.self) { (response, error) in
            if let response = response {
                // To authenticate Udacity API requests, we need to get a session ID:
                Auth.userId = response.account.key
                Auth.sessionId = response.session.id
                getPulicUserData { success, error in
                    if success {
                        completionHandler(true, nil)
                    } else {
                        completionHandler(false, error)
                    }
                }
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func getStudentInformation(completionHandler: @escaping ([StudentInformation.StudentsData], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.order(limit: 100, sorted: "-updatedAt").url, getPublicUserData: false, responseType: StudentInformation.self) { (response, error) in
            if let response = response {
                completionHandler(response.results, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
    
    class func postUserInformation(mapString: String, mediaURL: String, mapCoord: CLLocation, completionHandler: @escaping (Bool, Error?) -> Void) {
        let body = createHttpBody(mapString: mapString, mediaURL: mediaURL, mapCoord: mapCoord)
        
        taskForPOSTRequest(url: Endpoints.studentLocation.url, getSessionId: false, body: body, responseType: StudentLocationResponse.self) { (response, error) in
            if let response = response {
                Auth.objectId = response.objectId
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
   
    class func updateUserInformation(mapString: String, mediaURL: String, mapCoord: CLLocation, completionHandler: @escaping(Bool, Error?) -> Void) {
        let body = createHttpBody(mapString: mapString, mediaURL: mediaURL, mapCoord: mapCoord)
        
        taskForPUTRequest(url: Endpoints.objectId.url, body: body, responseType: UpdateStudentLocationResponse.self) { (response, error) in
            if response != nil {
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func logout(completionHandler: @escaping (Bool, Error?) -> Void) {
        taskForDELETERequest(url: Endpoints.sessionId.url, responseType: DeleteResponse.self) { (response, error) in
            if response != nil {
                Auth.userId = ""
                Auth.firstName = ""
                Auth.lastName = ""
                Auth.sessionId = ""
                Auth.objectId = ""
                Auth.pinAlreadyPosted = false
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func createHttpBody(mapString: String, mediaURL: String, mapCoord: CLLocation) -> StudentInformation.StudentsData {
        let body = StudentInformation.StudentsData(
            createdAt: nil,
            firstName: Auth.firstName,
            lastName: Auth.lastName,
            latitude: mapCoord.coordinate.latitude,
            longitude: mapCoord.coordinate.longitude,
            mapString: mapString,
            mediaURL: mediaURL,
            objectId: nil,
            uniqueKey: Auth.userId,
            updatedAt: nil
        )
        return body
    }
}
