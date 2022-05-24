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
        static var userId = "11193021052"
        static var objectId = "" //"c9t2intc4s60t6a96dh0"
        static var accountId = ""
        static var sessionId = ""
        static var registered = false
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
        case uniqueKey(String)
        case objectId(String)
        case sessionId
        case publicUserData(String)
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
            case .uniqueKey(let userId):
                return Endpoints.base + Endpoints.studentLocationPath + "?uniqueKey=\(userId)"
            // the object ID of the StudentLocation to update:
            case .objectId(let theId):
                return Endpoints.base + Endpoints.studentLocationPath + "/\(theId)"
            case .sessionId:
                return Endpoints.base + Endpoints.sessionPath
            case .publicUserData(let userId):
                return Endpoints.base + Endpoints.userIdPath + "/\(userId)"
            case .signUp:
                return "https://auth.udacity.com/sign-up"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - GETing multiple student locations at one time:
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
           
            let decoder = JSONDecoder()
            //decoder.dateDecodingStrategy = .iso8601
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

    // MARK: - POSTing a new student location and a session:
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, gettingSessionId: Bool, body: RequestType, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        if gettingSessionId {
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
                if gettingSessionId {
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
            //print(String(data: data, encoding: .utf8)!)
            
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
        let request = URLRequest(url: Endpoints.publicUserData(Auth.userId).url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else { // Handle error...
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            completionHandler(true, nil)
            // Need to built a struct for mapping out this horrendously complicated JSON:
            print(String(data: newData, encoding: .utf8)!)
        }
        task.resume()
    }
    
    // MARK: - Requests
    class func login(username: String, password: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: LoginRequest.AuthPair(username: username, password: password))
        
        taskForPOSTRequest(url: Endpoints.sessionId.url, gettingSessionId: true, body: body, responseType: SessionResponse.self) { (response, error) in
            if let response = response {
                // To authenticate Udacity API requests, we need to get a session ID:
                Auth.sessionId = response.session.id
                Auth.registered = response.account.registered
                completionHandler(true, nil)
                print("\(response)\n")
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func getStudentInformation(completionHandler: @escaping ([StudentInformation.StudentsData], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.order(limit: 100, sorted: "-updatedAt").url, responseType: StudentInformation.self) { (response, error) in
            if let response = response {
                completionHandler(response.results, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
    
    class func postUserInformation(mapString: String, mediaURL: String, mapCoord: CLLocation, completionHandler: @escaping (Bool, Error?) -> Void) {
        let lat = mapCoord.coordinate.latitude
        let long = mapCoord.coordinate.longitude
        
        let body = AddUserRequest(uniqueKey: Auth.userId, firstName: "Ken", lastName: "Gutierrez", mapString: mapString, mediaURL: mediaURL, latitude: lat, longitude: long)
        
        taskForPOSTRequest(url: Endpoints.studentLocation.url, gettingSessionId: false, body: body, responseType: StudentLocationResponse.self) { (response, error) in
            if response != nil {
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func checkPinBeenPosted(uniqueKey: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.uniqueKey(uniqueKey).url, responseType: StudentLocationResponse.self) { (response, error) in
            if response != nil {
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func updateUserInformation(mapString: String, mediaURL: String, mapCoord: CLLocation, completionHandler: @escaping(Bool, Error?) -> Void) {
        let lat = mapCoord.coordinate.latitude
        let long = mapCoord.coordinate.longitude
        
        let body = AddUserRequest(uniqueKey: Auth.userId, firstName: "Ken", lastName: "Gutierrez", mapString: mapString, mediaURL: mediaURL, latitude: lat, longitude: long)
        
        taskForPUTRequest(url: Endpoints.objectId(Auth.userId).url, body: body, responseType: UpdateStudentLocationResponse.self) { (response, error) in
            if response != nil {
                completionHandler(true, nil)
                print("\(String(describing: response))")
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func logout(completionHandler: @escaping (Bool, Error?) -> Void) {
        taskForDELETERequest(url: Endpoints.sessionId.url, responseType: DeleteResponse.self) { (response, error) in
            if response != nil {
                Auth.sessionId = ""
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
}
