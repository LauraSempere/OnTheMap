//
//  Alert.swift
//  OnTheMap
//
//  Created by Laura Scully on 24/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import Foundation
import UIKit

class Alert: UIViewController {

    func show(currentVC:AnyObject, title:String, message:String, actionText:String, additionalAction: UIAlertAction?){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: actionText, style: UIAlertActionStyle.Default) {
            action in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
        }
        alertVC.addAction(action)
        if let additionalAction = additionalAction {
            alertVC.addAction(additionalAction)
        }
        
        currentVC.presentViewController(alertVC, animated: true, completion: nil)
    }

}