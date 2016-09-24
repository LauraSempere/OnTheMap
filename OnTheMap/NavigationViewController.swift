//
//  NavigationViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 24/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

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
        self.presentViewController(sendInfoVC!, animated: true, completion: nil)
    }
}
