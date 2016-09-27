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
        
        authenticateUser(jsonData) { (success, userData, errorString) in
            if success {
                hander(success: true, errorString: nil)
                self.currentStudent = StudentInformation(info: userData!)
                print("Current Student ---> \(self.currentStudent)")
                //self.currentStudent.uniqueKey = userData["uniqueKey"]
                //self.currentStudent.uniqueKey = accountKey!
               // self.accountKey = accountKey
            }else{
                hander(success: false, errorString: errorString)
            }
        }
    }
    
    private func authenticateUser(jsonData:NSData, completionHandler: (success: Bool, userData:[String: AnyObject]?, errorString:String?) -> Void){
        
        taskForPOSTMethod(Methods.Auth,params: [:], jsonBody: jsonData){(result, error) in
            if let error = error {
                print("Error authenticating user: \(error)")
                completionHandler(success: false, userData: nil, errorString: error.localizedDescription)
            }else {
                if let account = result["account"] {
                    if let accountKey = account!["key"] as? String {
                        self.getUserData(accountKey, completionHandlerForUserData: { (success, userData, errorString) in
                            if success {
                                guard let user = userData["user"] else {
                                    completionHandler(success: false, userData: nil, errorString: "No user found in the response")
                                    return
                                }
                                var firstName = String()
                                var lastName = String()
                                
                                if let fName = user!["first_name"] as? String {
                                    firstName = fName
                                }
                                if let lName = user!["last_name"] as? String {
                                    lastName = lName
                                }
                                completionHandler(success: true, userData: ["firstName":firstName, "lastName":lastName, "uniqueKey": accountKey], errorString: nil)
                            } else {
                                completionHandler(success: false, userData: nil, errorString: errorString)
                            }
                        })
                        
                    }
                }else {
                    completionHandler(success: false, userData: nil, errorString: "No account Key found")
                }
            }
        }
    }
    
    private func getUserData(accountKey:String, completionHandlerForUserData: (success: Bool, userData:AnyObject!, errorString: String?) -> Void)  {
        let method = Methods.Users + "/" + accountKey
        
        taskForGETMethod(method, params: nil) { (result, error) in
            guard (error == nil) else {
                completionHandlerForUserData(success: false, userData: nil, errorString: error?.localizedDescription)
                return
            }
            completionHandlerForUserData(success: true, userData: result, errorString: nil)
        }
        
    }
    
    private func taskForGETMethod(method:String, params:[String:AnyObject]?, completionHandler:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let url = udacityURLFromParams(params, method: method)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request){data, response, error in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }

            
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Status Code different from 2xx")
                return
            }
            
            guard let data = data else {
                sendError("No user found")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: { (result, error) in
                guard (error == nil) else {
                    completionHandler(result: nil, error: error)
                    return
                }
                
                completionHandler(result: result, error: nil)
                
            })
            
        }
        task.resume()
        
        return task

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
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandler(success: false, errorString: "Something went wrong. Check that you have Internet connection and try again.")
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, errorString: "Something went wrong. Check that you have Internet connection and try again.")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: { (result, error) in
                guard (error == nil) else {
                    completionHandler(success: false, errorString: error?.localizedDescription)
                    return
                }
                guard let result = result else {
                    completionHandler(success: false, errorString: "No session found")
                    return
                }
                guard let session = result["session"] else {
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