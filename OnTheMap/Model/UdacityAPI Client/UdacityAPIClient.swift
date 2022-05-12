//
//  UdacityAPIClient.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import Foundation

class UdacityAPIClient {
    
    // Authentication Properties:
    struct Auth {
        static var userId = ""
        static var objectId = "c9t2intc4s60t6a96dh0"
        static var accountId = ""
        static var sessionId = ""
    }

    // Udacity API URL's:
    enum Endpoints {
        static let studentLocationURL = "https://onthemap-api.udacity.com/v1/StudentLocation"
        static let sessionURL = "https://onthemap-api.udacity.com/v1/session"
        static let userIdURL = "https://onthemap-api.udacity.com/v1/users"
        
        case location
        case limit(Int)
        case skip(Int)
        case order(String)
        case uniqueKey(String)
        case objectId(String)
        case session
        case publicUserData(String)
        
        var stringValue: String {
            switch self {
            case .location:
                return Endpoints.studentLocationURL
            // specifies the maximum number of StudentLocation objects to return in the JSON response:
            case .limit(let maxNumberedReturn):
                return Endpoints.studentLocationURL + "?limit=\(maxNumberedReturn)"
            // use this parameter with limit to paginate through results:
            case .skip(let limitPaginate):
                return "&skip=\(limitPaginate)"
            /*
             a comma-separate list of key names that specify the sorted order of the results:
             Prefixing a key name with a negative sign reverses the order (default order is ascending):
             */
            case .order(let keyName):
                return Endpoints.studentLocationURL + "?order=\(keyName)"
            // a unique key (user ID). Gets only student locations with a given user ID:
            case .uniqueKey(let userId):
                return Endpoints.studentLocationURL + "?uniqueKey=\(userId)"
            // the object ID of the StudentLocation to update:
            case .objectId(let theId):
                return Endpoints.studentLocationURL + "/\(theId)"
            case .session:
                return Endpoints.sessionURL
            case .publicUserData(let userId):
                return Endpoints.userIdURL + "/\(userId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // GETing multiple student locations at one time:
    func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            //print(String(data: data, encoding: .utf8)!)
            let decoder = JSONDecoder()
            //decoder.dateDecodingStrategy = .iso8601
            do {
                let responseObject = try decoder.decode(responseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }

    // POSTing a new student location:
    func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, postingSession: Bool, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        if postingSession {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // HACK: this line allows the workspace or an Xcode playground to execute the request, but is not needed in a real app:
        //let runLoop = CFRunLoopGetCurrent()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard var data = data else { // Handle error…
                completion(nil, error)
                return
            }
            //print(String(data: data, encoding: .utf8)!)
            
            if postingSession {
                let range = 5..<data.count
                data = data.subdata(in: range) /* subset response data! */
            }
            
            let decoder = JSONDecoder()
            //decoder.dateDecodingStrategy = .iso8601
            do {
                let responseObject = try decoder.decode(responseType.self, from: data)
                completion(responseObject, nil)
            } catch {
                completion(nil, error)
            }
            // also not necessary in a real app:
            //CFRunLoopStop(runLoop)
        }
        task.resume()
        // not necessary:
        //CFRunLoopRun()
    }

    // PUTing a student location by update an existing student location:
    func taskForPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType.self, from: data)
                completion(responseObject, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }

    func taskForPOSTSession<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // encoding a JSON body from a string, can also use a Codable struct
        // "{\"udacity\": {\"username\": \"kennethjoe1@icloud.com\", \"password\": \"fuDfaj-kunbyt-4goggo\"}}".data(using: .utf8)
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                completion(nil, error)
                return
            }
            //print(String(data: data!, encoding: .utf8)!)
            
            /*
             FOR ALL RESPONSES FROM THE UDACITY API, YOU WILL NEED TO SKIP THE FIRST 5 CHARACTERS OF THE
             RESPONSE. These characters are used for security purposes.
             */
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType.self, from: newData!)
                //Auth.sessionId = newData.session.id
                completion(responseObject, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }

    func taskForDELETERequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
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
                completion(nil, error)
                return
            }
            //print(String(data: data, encoding: .utf8)!)
            
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            
            let decoder = JSONDecoder()
            do {
                let respondObject = try decoder.decode(responseType.self, from: newData)
                completion(respondObject, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    // retrieve some basic user information before posting data to Parse(Udacity):
    func getPulicUserData() {
        let request = URLRequest(url: Endpoints.publicUserData(Auth.userId).url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            // Need to built a struct for mapping out this horrendously complicated JSON:
            print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
    }
    
}
