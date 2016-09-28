//
//  ViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 20/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    let colors = Colors()
    
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
        
        textFieldInit(usernameTextField, placeholder:"Username")
        textFieldInit(passwordTextField, placeholder:"Password")
        loginButton.layer.cornerRadius = 8

    }
    
    override func viewWillAppear(animated: Bool) {
        if loginOutLoading {
            loginoutLoadingState(true)
        } else {
            loginoutLoadingState(false)
        }
    }
    
    func toggleLoadingState(loading:Bool){
        if loading {
            activityIndicatorView.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicatorView.hidden = true
            activityIndicator.stopAnimating()
        }
        
    }
    
    func textFieldInit(textField: UITextField, placeholder: String) {
        var padding = UIView(frame: CGRectMake(0, 0, 15, 15))
        textField.leftView = padding
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.backgroundColor = colors.semitransparent
        textField.layer.cornerRadius = 8
        textField.placeholder = placeholder
        textField.textColor = colors.darkOrange
    }
    
    func setTextFieldToInvalid(textfield:UITextField, text: String){
        textfield.layer.borderWidth = 2
        textfield.layer.borderColor = colors.red.CGColor
        textfield.textColor = colors.red
        textfield.text = text
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func validateTextFields() -> Bool {
        var validEmail:Bool = false
        var validPassword:Bool = false
        
        if isValidEmail(usernameTextField.text!) {
            validEmail = true
        } else {
            validEmail = false
            setTextFieldToInvalid(usernameTextField, text: "Username must be a valid email")
        }
        
        if !(passwordTextField.text?.isEmpty)! {
            validPassword = true
        } else {
            validPassword = false
            setTextFieldToInvalid(passwordTextField, text: "Password is required")
            passwordTextField.secureTextEntry = false
        }
        
        return (validEmail && validPassword)
    }
    
    func loginoutLoadingState(loading:Bool) {
        toggleLoadingState(loading)
        udacityLogo.hidden = !loading
        loginFormView.hidden = loading
    }
    
    

    @IBAction func login(sender: AnyObject) {
        if validateTextFields() {
            
        
            toggleLoadingState(true)
            UdacityClient.sharedInstance().loginWithCredentitals(usernameTextField.text!, password: passwordTextField.text!){(success: Bool, errorString:String?) in
                if success {
                    performUIUpdatesOnMain{
                        self.toggleLoadingState(false)
                        let tabBarVC = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                        self.presentViewController(tabBarVC, animated: true, completion: nil)
                    }
                } else {
                    performUIUpdatesOnMain{
                        self.toggleLoadingState(false)
                        self.displayError(errorString)
                    }
                }
                
            }
        
        }
    }
    
    @IBAction func signup(sender: AnyObject) {
        app.openURL(NSURL(string: "https://auth.udacity.com/sign-up")!)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.layer.borderWidth = 0
        textField.textColor = colors.darkOrange
        if textField == passwordTextField {
            textField.secureTextEntry = true
        }
        return true
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

