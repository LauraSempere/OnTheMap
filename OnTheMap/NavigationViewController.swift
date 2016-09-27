//
//  NavigationViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 24/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    
    let parseClient = ParseClient.sharedInstance()
    let udacityClient = UdacityClient.sharedInstance()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinIconImage = UIImage(named: "pin")

                let leftItem = UINavigationItem()
        leftItem.leftBarButtonItem = UIBarButtonItem(image: pinIconImage, style: UIBarButtonItemStyle.Done, target: self, action: #selector(NavigationViewController.showSendInfoViewController))
        leftItem.title = "On The Map"
        leftItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:
            .Redo, target: self, action: #selector(NavigationViewController.sayHi))
        self.navigationBar.items =  [leftItem]
    }
    
    func sayHi () {
        print("Hi")
    }
    
    func showSendInfoViewController(){
        let sendInfoVC = self.storyboard?.instantiateViewControllerWithIdentifier("SendInfoVC") as? SendInformationViewController
        sendInfoVC?.showActivityIndicatior = true
        
        self.presentViewController(sendInfoVC!, animated: true) {
            self.parseClient.getStudentInfo { (success, errorString) in
                if success {

                    let updateAction = UIAlertAction(title: "Update", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                         sendInfoVC?.toggleActivityIndicator(false)
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                        sendInfoVC!.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    performUIUpdatesOnMain({
                        let alert = Alert()
                        alert.show(sendInfoVC!, title: "Update Location", message: "You already have submitted your location. Do you want to update it?", withCustomActions: [updateAction, cancelAction])
                    })
                    
                } else {
                    performUIUpdatesOnMain({ 
                      sendInfoVC?.toggleActivityIndicator(false)
                    })
                }
            }
        }
    }
}
