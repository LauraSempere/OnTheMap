//
//  ViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 20/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugTextLabel.text = ""
        activityIndicatorView.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUILoadingState(loading:Bool){
        if loading {
            activityIndicatorView.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicatorView.hidden = true
            activityIndicator.stopAnimating()
        }
        
    }

    @IBAction func login(sender: AnyObject) {
        updateUILoadingState(true)
        UdacityClient.sharedInstance().loginWithCredentitals(usernameTextField.text!, password: passwordTextField.text!){(success: Bool, errorString:String?) in
            performUIUpdatesOnMain {
                if success {
                    print("Login in successfully!")
                    self.displayError("Login Successfully")
                    self.updateUILoadingState(false)
                    let tabBarVC = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(tabBarVC, animated: true, completion: nil)
                }else{
                    print("Login Failed")
                    self.updateUILoadingState(false)
                    self.displayError(errorString)
                }
            }
        }
    }
    
    @IBAction func signup(sender: AnyObject) {
    
    }
    
    private func displayError(error:String?) {
        if let error = error {
            debugTextLabel.text = error
        }
    }

}

