//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Laura Scully on 21/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import Foundation

class ParseClient:HTTPClient {
    
    let session = NSURLSession.sharedSession()
    var studentsInformation = [StudentInformation()]
    let udacityClient = UdacityClient.sharedInstance()
    
    func getStudentsInformation(completionHandlerForStudentsLocation handler:(success:Bool, errorString:String?) -> Void) {
        
        getInfoFromParse() {(success, studentsInfo, errorString) in
            if success {
                self.studentsInformation = studentsInfo!
                    handler(success: true, errorString: nil)
            } else {
                handler(success: false, errorString: errorString)
            }
        }
        
    }
    
    private func getInfoFromParse(completionHandler: (success: Bool, studentsInfo: [StudentInformation]?, errorString: String?) -> Void){
        taskForGETMethod(Methods.StudentLocation,url: nil, params: ["limit": 100, "order": "-updatedAt"]) { (result, error) in
            if let error = error {
                completionHandler(success: false, studentsInfo: nil, errorString: error.localizedDescription)
            }else {
                self.createStudentInfo(result, completionHandlerForCreateStudent: { (students, error) in
                    if let error = error {
                        completionHandler(success: false, studentsInfo: nil, errorString: error)
                    }else {
                        self.studentsInformation = students!
                        completionHandler(success: true, studentsInfo: students, errorString: nil)
                    }
                })
            
            }
        }
        
    }
    
    func sendStudentInfo(info: [String:AnyObject], completionHandlerForSendingInfo handler:(success: Bool, objectId: String?, errorString: String?) -> Void){
        let jsonBody = convertObjectToData(info)
        taskForSendDataMethod("POST",method: Methods.StudentLocation, jsonBody: jsonBody) { (result, error) in
            if let err = error {
                handler(success: false, objectId: nil, errorString: err.localizedDescription)
            } else {
                if let objectId = result["objectId"] as? String {
                    handler(success: true, objectId: objectId, errorString: nil)
                   
                } else {
                    handler(success: false, objectId: nil, errorString: "No objectId found")
                }
                
            }
        }
        
    }
   
    private func taskForSendDataMethod(httpMethod:String, method:String, jsonBody: NSData!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let url = parseApiURLFromParams(method, params: nil)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = httpMethod
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonBody = jsonBody {
            request.HTTPBody = jsonBody
        }
        let task = session.dataTaskWithRequest(request){(data, response, error) in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("Network connection failure")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (result, error) in
                guard(error == nil) else {
                    print("Error parsing data: \(error)")
                    sendError(error!.localizedDescription)
                    return
                }
                
                if let err = result["error"] as? String {
                    sendError(err)
                } else {
                    completionHandler(result: result, error: nil)
                }
            })
            
        }
        task.resume()
        return task
        
    }
    
    func getStudentInfo(completionHandler handler:(success: Bool, errorString:String?) -> Void) {
        let uniqueKey = udacityClient.currentStudent.uniqueKey
        let queryString = "{\"uniqueKey\":\"\(uniqueKey)\"}"
        let queryStringEncoded = queryString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let url = NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=\(queryStringEncoded!)")
        
        taskForGETMethod(nil, url: url, params: nil) { (result, error) in
            if let err = error {
                handler(success: false, errorString: err.localizedDescription)
                print("Error:\(error)")
            } else {
                guard let results = result["results"] as? [AnyObject] else {
                    handler(success: false, errorString: "No User found in the DB")
                    return
                }
                if results.isEmpty{
                    handler(success: false, errorString: "No user found in the DB")
                
                } else {
                    guard let result = results[0] as? [String:AnyObject] else {
                        handler(success: false, errorString: "No User found in the DB")
                        return
                    }
                    self.udacityClient.currentStudent = StudentInformation(info: result)
                    handler(success: true, errorString: nil)
                }
                
            }
        }
        
    }
    
    private func taskForGETMethod(method: String!, url:NSURL!, params:[String:AnyObject]!, completionHandler:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let reqURL:NSURL!
       
        if let url = url {
            reqURL = url
        } else {
            reqURL = parseApiURLFromParams(method, params: params)
        }
        
        let request = NSMutableURLRequest(URL: reqURL!)
        request.HTTPMethod = "GET"
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("Network connection failure")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (result, error) in
                guard(error == nil) else {
                    print("Error parsing data")
                    return
                }
                
                if let err = result["error"] as? String {
                    sendError(err)
                } else {
                    completionHandler(result: result, error: nil)
                }
            })
        }
        task.resume()
        
        return task
    }
    
    private func createStudentInfo(parsedResult:AnyObject, completionHandlerForCreateStudent:(students: [StudentInformation]?, error:String?) -> Void){
        guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
            print("No results found")
            completionHandlerForCreateStudent(students: nil, error: "No 'results' found in the response")
            return
        }
        var studentsInfo = [StudentInformation]()
        for result in results {
            let student = StudentInformation(info: result)
            studentsInfo.append(student)
        }
        completionHandlerForCreateStudent(students: studentsInfo, error: nil)
    }
    
    func updateStudentInfo(userInfo:[String:AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void){
        let objectId = udacityClient.currentStudent.objectId
        let method = Methods.StudentLocation + "/" + objectId
        let jsonBody = convertObjectToData(userInfo)
        taskForSendDataMethod("PUT", method: method, jsonBody: jsonBody) { (result, error) in
            if let err = error {
                print("Error putting the data: \(err)")
                completionHandler(success: false, errorString: error?.localizedDescription)
            } else {
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    private func parseApiURLFromParams(method:String, params:[String:AnyObject]?) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = method
        
        if let params = params {
            components.queryItems = [NSURLQueryItem]()
            for (key, value) in params {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        return components.URL!
    }

    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }

}
