//
//  ViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 20/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginFormView: UIStackView!
    @IBOutlet weak var udacityLogo: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let alert = Alert()
    let app = UIApplication.sharedApplication()
    var loginOutLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.hidden = true
        udacityLogo.hidden = true
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.secureTextEntry = true

    }
    
    override func viewWillAppear(animated: Bool) {
        if loginOutLoading {
            loginoutLoadingState(true)
        } else {
            loginoutLoadingState(false)
        }
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
    
    func loginoutLoadingState(loading:Bool) {
        updateUILoadingState(loading)
        udacityLogo.hidden = !loading
        loginFormView.hidden = loading
    }

    @IBAction func login(sender: AnyObject) {
        updateUILoadingState(true)
        UdacityClient.sharedInstance().loginWithCredentitals(usernameTextField.text!, password: passwordTextField.text!){(success: Bool, errorString:String?) in
            if success {
                print("Login in successfully!")
                performUIUpdatesOnMain{
                    self.updateUILoadingState(false)
                    let tabBarVC = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(tabBarVC, animated: true, completion: nil)
                }
            } else {
                print("Login Failed")
                performUIUpdatesOnMain{
                    self.updateUILoadingState(false)
                    self.displayError(errorString)
                }
            }
            
        }
    }
    
    @IBAction func signup(sender: AnyObject) {
        app.openURL(NSURL(string: "https://auth.udacity.com/sign-up")!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    private func displayError(error:String?) {
        if let error = error {
            alert.show(self, title: "Login Failed", message: error, actionText: "Dismiss", additionalAction: nil)
        }
    }

}

