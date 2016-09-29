//
//  Students.swift
//  OnTheMap
//
//  Created by Laura Scully on 29/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import Foundation

class Students {
    
    var studentsInformation = [StudentInformation]()

    class func sharedInstance() -> Students {
        struct Singleton {
            static var sharedInstance = Students()
        }
        return Singleton.sharedInstance
    }

}