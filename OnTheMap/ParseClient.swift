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
        taskForGETMethod() { (result, error) in
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
    
    func sendStudentInfo(info: [String:AnyObject], completionHandlerForSendingInfo handler:(success: Bool, errorString: String?) -> Void){
        let jsonBody = convertObjectToData(info)
        taskForPOSTMethod(nil, jsonBody: jsonBody) { (result, error) in
            if let err = error {
                handler(success: false, errorString: err.localizedDescription)
            } else {
                self.getStudentsInformation(completionHandlerForStudentsLocation: { (success, errorString) in
                    handler(success: true, errorString: nil)
                })
                
            }
        }
        
        
        }
   
    private func taskForPOSTMethod(params:[String:AnyObject]?, jsonBody: NSData!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let url = parseApiURLFromParams(params)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
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
                sendError("There was an error in the request: \(error)")
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
    
    private func taskForGETMethod(completionHandler:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let url = parseApiURLFromParams(["limit":4])
        let request = NSMutableURLRequest(URL: url)
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
                sendError("There was an error with your request: \(error)")
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
    
    private func parseApiURLFromParams(params:[String:AnyObject]?) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Methods.StudentLocation
        
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
