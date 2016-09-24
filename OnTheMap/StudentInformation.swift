//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Laura Scully on 21/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import Foundation

struct StudentInformation{
    var latitude = Double()
    var longitude = Double()
    var mediaURL = String()
    var mapString = String()
    var objectId = String()
    var firstName = String()
    var lastName = String()
    var uniqueKey = Int()
    var createdAt = String()
    var updatedAt = String()
    
    init(info: [String: AnyObject]){
        
        if let lat = info["latitude"] as? Double {
            self.latitude = lat
        }
        
        if let lon = info["longitude"] as? Double {
            self.latitude = lon
        }
        
        if let mURL = info["mediaURL"] as? String {
            self.mediaURL = mURL
        }
        
        if let obID = info["objectId"] as? String {
            self.objectId = obID
        }
        
        if let firstName = info["firstName"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = info["lastName"] as? String {
            self.lastName = lastName
        }
        
        if let mapString = info["mapString"] as? String {
            self.mapString = mapString
        }
        
        if let uniqueKey = info["uniqueKey"] as? Int {
            self.uniqueKey = uniqueKey
        }
        
        if let updatedAt = info["updatedAt"] as? String {
            self.updatedAt = updatedAt
        }
        
        if let createdAt = info["createdAt"] as? String {
            self.createdAt = createdAt
        }
    }
    
    init(){
    
    }
    
}