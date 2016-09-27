//
//  UdacityAuthentication.swift
//  OnTheMap
//
//  Created by Laura Scully on 20/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import Foundation

class UdacityClient:HTTPClient {
    
    let session = NSURLSession.sharedSession()
   // var accountKey:String!
    var currentStudent = StudentInformation()
    
    private func udacityURLFromParams(params:[String:AnyObject]? = nil, method:String? = nil) -> NSURL {
        
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
    
    func loginWithCredentitals(username:String, password:String, completionHandler hander: (success: Bool, errorString: String?) ->Void ) {
        
        let jsonData:NSData! = convertObjectToData(["udacity": ["username": username, "password": password]])
        
        authenticateUser(jsonData) { (success, accountKey, errorString) in
            if success {
                hander(success: true, errorString: nil)
                self.currentStudent.uniqueKey = accountKey!
               // self.accountKey = accountKey
            }else{
                hander(success: false, errorString: errorString)
            }
        }
    }
    
    private func authenticateUser(jsonData:NSData, completionHandler: (success: Bool, accountKey:String?, errorString:String?) -> Void){
        
        taskForPOSTMethod(Methods.Auth,params: [:], jsonBody: jsonData){(result, error) in
            if let error = error {
                print("Error authenticating user: \(error)")
                completionHandler(success: false, accountKey: nil, errorString: error.localizedDescription)
            }else {
                if let account = result["account"] {
                    if let accountKey = account!["key"] as? String {
                        completionHandler(success: true, accountKey: accountKey, errorString: nil)
                    }
                }else {
                    completionHandler(success: false, accountKey: nil, errorString: "Could not find account key")
                }
            }
        }
    }
    
    private func taskForPOSTMethod(method: String, params: [String:AnyObject], jsonBody:NSData!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let url = udacityURLFromParams(params, method: method)
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonBody = jsonBody {
            request.HTTPBody = jsonBody
        }
        
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
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            let parsedData = self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: { (result, error) in
                guard(error == nil) else{
                    print("Error parsing data")
                    return
                }
                if let loginError = result["error"] as? String {
                    sendError(loginError)
                
                } else {
                    completionHandler(result: result, error: nil)
                }
            })
            
        }
        task.resume()
        
        return task
    
    }
    
    func logout(completionHandler:(success:Bool, errorString:String?) -> Void){
        let url = udacityURLFromParams(nil, method: Methods.Auth)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie:NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN"{
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTaskWithRequest(request){(data, response, error) in
            guard(error == nil) else {
                completionHandler(success: false, errorString: error!.localizedDescription)
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, errorString: "Log out failed")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: { (result, error) in
                guard (error == nil) else {
                    completionHandler(success: false, errorString: error?.localizedDescription)
                    return
                }
                guard (result["session"] != nil) else {
                    completionHandler(success: false, errorString: "No session found")
                    return
                }
                completionHandler(success: true, errorString: nil)
            })
        }
        
        task.resume()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}