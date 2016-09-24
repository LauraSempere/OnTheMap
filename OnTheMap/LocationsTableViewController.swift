//
//  LocationsTableViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 24/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {
   
    let parseClient = ParseClient.sharedInstance()
    let app = UIApplication.sharedApplication()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseClient.studentsInformation.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentsCell", forIndexPath: indexPath)
       
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel!.text = parseClient.studentsInformation[indexPath.row].firstName + " " + parseClient.studentsInformation[indexPath.row].lastName

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentURL:String!
        studentURL = parseClient.studentsInformation[indexPath.row].mediaURL
        let url:NSURL! = NSURL(string: studentURL)
        if let url = url {
            app.openURL(url)
        }
    }

}
