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
    var loading = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func refreshData(){
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseClient.studentsInformation.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentsCell", forIndexPath: indexPath) as! studentsLocationCell
       
        cell.icon.image = UIImage(named: "pin")
        cell.name.text = parseClient.studentsInformation[indexPath.row].firstName + " " + parseClient.studentsInformation[indexPath.row].lastName
        if loading {
            cell.activityIndicator.hidden = false
            cell.name.hidden = true
            cell.activityIndicator.startAnimating()
        } else {
            cell.activityIndicator.hidden = true
            cell.name.hidden = false
            cell.activityIndicator.stopAnimating()
        }
        
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
