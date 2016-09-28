//
//  SendInformationViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 24/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit
import MapKit

class SendInformationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var submitLocationView:UIStackView!
    @IBOutlet weak var submitMediaURLView:UIStackView!
    
    @IBOutlet weak var locationTextField:UITextField!
    @IBOutlet weak var parseLocationStringButton:UIButton!
    
    @IBOutlet weak var mediaURLTextField:UITextField!
    @IBOutlet weak var submitLocationButton:UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!
    
    let alert = Alert()
    let parseClient = ParseClient.sharedInstance()
    let udacityClient = UdacityClient.sharedInstance()
    var showActivityIndicatior:Bool = false
    var colors = Colors()
    
    override func viewWillAppear(animated: Bool) {
        if showActivityIndicatior {
            toggleActivityIndicator(true)
        } else {
            toggleActivityIndicator(false)
        }
    }
    
    func roundedWhiteButton(button: UIButton){
        button.layer.cornerRadius = 8
        button.tintColor = colors.blue
        button.backgroundColor = colors.beige
        button.layer.borderColor = colors.lightgrey.CGColor
        button.layer.borderWidth = 1
    }
    
    func initUI(){
        locationTextField.backgroundColor = colors.blue
        mediaURLTextField.backgroundColor = colors.blue
        roundedWhiteButton(parseLocationStringButton)
        roundedWhiteButton(submitLocationButton)
        roundedWhiteButton(cancelButton)
        
        submitLocationView.hidden = false
        submitMediaURLView.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        mediaURLTextField.delegate = self
        initUI()
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
        let location = CLGeocoder()
        self.toggleActivityIndicator(true)
        location.geocodeAddressString(locationTextField.text!) { (placemark: [CLPlacemark]?, error: NSError?) in
            if let err = error {
                print("Error: \(err)")
                self.toggleActivityIndicator(false)
                self.alert.show(self, title:"Error Getting your Location", message: "Please provide a correct address, city or country", actionText: "Dismiss", additionalAction: nil)
            } else {
                if let location = placemark!.last?.location {
                    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
                    
                    self.mapView.setRegion(region, animated: true)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    annotation.title = self.locationTextField.text!
                    self.mapView.addAnnotation(annotation)
                    
                    self.submitMediaURLView.hidden = false
                    self.submitLocationView.hidden = true
                    self.toggleActivityIndicator(false)
                    
                    self.udacityClient.currentStudent.latitude = location.coordinate.latitude
                    self.udacityClient.currentStudent.longitude = location.coordinate.longitude
                    self.udacityClient.currentStudent.mapString = self.locationTextField.text!
                    
                } else {
                    self.alert.show(self, title: "No location found", message: "Could not find your location. Please try again", actionText: "Dismiss", additionalAction:   nil)
                    self.toggleActivityIndicator(false)
                }
                
            }
        }
    
    }
    
    
    private func sendUserInformation(userInfo:[String:AnyObject]){
        parseClient.sendStudentInfo(userInfo, completionHandlerForSendingInfo: { (success, objectId,errorString) in
            if success {
                self.udacityClient.currentStudent.objectId = objectId!
                
                // Call Parse API again to get the student's data updated
                self.parseClient.getStudentsInformation(completionHandlerForStudentsLocation: { (success, errorString) in
                    if success {
                        self.toggleActivityIndicator(false)
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                    } else {
                        self.toggleActivityIndicator(false)
                        self.alert.show(self, title: "Error updating students' locations", message: errorString!, actionText: "Dismiss", additionalAction: nil)
                    }

                })
                
            } else {
                self.alert.show(self, title: "Error sending information", message: errorString!, actionText: "Dismiss", additionalAction: nil)
            }
            
        })
    }
    
    private func updateUserInformation(userInfo:[String:AnyObject]){
        parseClient.updateStudentInfo(userInfo) { (success, errorString) in
            if success {
            performUIUpdatesOnMain({
                self.toggleActivityIndicator(false)
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            } else {
                performUIUpdatesOnMain({
                    self.toggleActivityIndicator(false)
                    self.alert.show(self, title: "Error updating", message: errorString!, actionText: "Dismmiss", additionalAction: nil)
                })
            }
        }
    }
    
    @IBAction func submitLocationInformation(sender: AnyObject) {
        toggleActivityIndicator(true)
        if let mediaURL = mediaURLTextField.text {
            udacityClient.currentStudent.mediaURL = mediaURL
        }
        let userInfo:[String: AnyObject] = udacityClient.currentStudent.studentDictionary()
        
        if udacityClient.currentStudent.objectId.isEmpty {
            sendUserInformation(userInfo)
        } else {
            updateUserInformation(userInfo)
        }
        
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
