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
    let alert = Alert()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinIconImage = UIImage(named: "pin")

        let navigation = UINavigationItem()
        navigation.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Done, target: self, action: #selector(NavigationViewController.logout))
        navigation.title = "On The Map"
      
        let pinButton = UIBarButtonItem(image: pinIconImage, style: UIBarButtonItemStyle.Done, target: self, action: #selector(NavigationViewController.showSendInfoViewController))
        let reloadButton = UIBarButtonItem(barButtonSystemItem:
            .Refresh, target: self, action: #selector(NavigationViewController.refreshLocations))
        navigation.setRightBarButtonItems([reloadButton, pinButton], animated: true)
        self.navigationBar.items =  [navigation]
        
    }
    
    func refreshLocations(){
        if let mapVC = self.topViewController as? MapViewController {
            mapVC.setUILoadingState(true)
            parseClient.getStudentsInformation(completionHandlerForStudentsLocation: { (success, errorString) in
                if success {
                    performUIUpdatesOnMain({ 
                        mapVC.setUILoadingState(false)
                    })
                } else {
                    performUIUpdatesOnMain({
                        mapVC.setUILoadingState(false)
                        self.alert.show(mapVC, title: "Could not update", message: errorString!, actionText: "Dismiss", additionalAction: nil)
                    })
                }
            })
        }
        
        if let tableVC = self.topViewController as? LocationsTableViewController {
            tableVC.loading = true
            tableVC.refreshData()
            parseClient.getStudentsInformation(completionHandlerForStudentsLocation: { (success, errorString) in
                if success {
                    performUIUpdatesOnMain({
                        tableVC.loading = false
                        tableVC.refreshData()
                    })
                } else {
                    performUIUpdatesOnMain({
                        tableVC.loading = false
                        tableVC.refreshData()
                        self.alert.show(tableVC, title: "Could not update", message: errorString!, actionText: "Dismiss", additionalAction: nil)
                    })
                }
            })
        }
    }
    
    func logout() {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as? LoginViewController
        loginVC?.loginOutLoading = true
        self.presentViewController(loginVC!, animated: true) {
            self.udacityClient.logout { (success, errorString) in
                if success {
                    performUIUpdatesOnMain({
                        loginVC?.loginOutLoading = false
                        loginVC?.loginoutLoadingState(false)
                    })
                } else {
                    performUIUpdatesOnMain({
                        loginVC!.dismissViewControllerAnimated(true, completion: nil)
                        self.alert.show(self, title: "Logout Failed", message: errorString!, actionText: "Dismiss", additionalAction: nil)
                    })
                }
            }
        }
        
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
