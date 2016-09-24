//
//  SendInformationViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 24/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit
import MapKit

class SendInformationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var submitLocationView:UIStackView!
    @IBOutlet weak var submitMediaURLView:UIStackView!
    
    @IBOutlet weak var locationTextField:UITextField!
    @IBOutlet weak var parseLocationStringButton:UIButton!
    
    @IBOutlet weak var mediaURLTextField:UITextField!
    @IBOutlet weak var submitLocationButton:UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.hidden = true
        submitLocationView.hidden = false
        submitMediaURLView.hidden = true
        
        locationTextField.backgroundColor = UIColor.blueColor()
        mediaURLTextField.backgroundColor = UIColor.blueColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func toggleActivityIndicator(loading: Bool){
        if loading {
            activityIndicatorView.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicatorView.hidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func parseLocationString(sender: AnyObject) {
    var location = CLGeocoder()
        self.toggleActivityIndicator(true)
        location.geocodeAddressString(locationTextField.text!) { (placemark: [CLPlacemark]?, error: NSError?) in
            if let err = error {
                print("Error::::: \(err)")
                self.toggleActivityIndicator(false)
            } else {
                if let location = placemark!.last?.location {
                    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
                    
                    self.mapView.setRegion(region, animated: true)
                    self.submitMediaURLView.hidden = false
                    self.submitLocationView.hidden = true
                    self.toggleActivityIndicator(false)
                
                } else {
                    print("No location found")
                    self.toggleActivityIndicator(false)
                }
                
                
                
            }
        }
    
    }
    
    @IBAction func submitLocationInformation(sender: AnyObject) {

    }

}
