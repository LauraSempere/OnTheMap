//
//  HTTPClient.swift
//  OnTheMap
//
//  Created by Laura Scully on 25/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import Foundation

class HTTPClient:NSObject {
    
    // given raw JSON, return a usable Foundation object
     func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // Serializes Foundation object into JSON data
     func convertObjectToData(object:AnyObject) -> NSData! {
        var jsonData:NSData!
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
            
        }catch{
            print("Error serializing JSON data")
            
        }
        return jsonData
    }

}