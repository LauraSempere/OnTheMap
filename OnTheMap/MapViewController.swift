//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 21/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    let parseClient = ParseClient.sharedInstance()
    let students = Students.sharedInstance()

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let alert = Alert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        parseClient.getStudentsInformation { (success, errorString) in
            if success {
                performUIUpdatesOnMain{
                    self.setLocationPins()
                }
                
            } else {
                performUIUpdatesOnMain({ 
                    self.alert.show(self, title: "Error", message: errorString!, actionText: "Dismiss", additionalAction: nil)
                })
            }
        }
    }
    
    func setUILoadingState(loading: Bool) {
        if loading {
            activityIndicatorView.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicatorView.hidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    func setLocationPins(){
        let currentAnnotations = self.mapView.annotations
            for _annotation in currentAnnotations {
                if let annotation = _annotation as? MKAnnotation
                {
                    self.mapView.removeAnnotation(annotation)
                }
            }
        
        
    
        let locations = students.studentsInformation
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            let latitude = CLLocationDegrees(location.latitude)
            let longitude = CLLocationDegrees(location.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let firstName = location.firstName
            let lastName = location.lastName
            let mediaURL = location.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }

}
