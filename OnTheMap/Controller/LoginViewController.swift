//
//  ViewController.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import UIKit
import FBSDKLoginKit
//import FacebookLogin

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        setLogginIn(true)
        UdacityAPIClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completionHandler: handleLoginResponse(success:error:))
    }
    
    @IBAction func fbLoginButton(_ sender: UIButton) {
        setLogginIn(true)
        handleFBLoginManager(completionHandler: handleLoginResponse(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        UIApplication.shared.open(UdacityAPIClient.Endpoints.signUp.url, options: [:], completionHandler: nil)
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        setLogginIn(false)
        if success {
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            handleFailureAlert(title: "Login Failed", message: error?.localizedDescription ?? "Incorrect email and password.")
        }
    }
    
    func handleFBLoginManager(completionHandler: @escaping (Bool, Error?) -> Void) {
        let loginManager = LoginManager()
        
        if let _ = AccessToken.current {
            // Access token available—user already logged in:
            // Perform logout:
            loginManager.logOut()
        } else {
            // Access token not available—user already logged out:
            // Perform log in
            loginManager.logIn(permissions: [], from: self) { [weak self] (result, error) in
                // Check for error:
                guard error == nil else {
                    // Error occurred:
                    DispatchQueue.main.async {
                        completionHandler(false, error)
                    }
                    return
                }
                // Check for cancel:
                guard let result = result, !result.isCancelled else {
                    self?.setLogginIn(false)
                    self?.handleFailureAlert(title: "Continue with FB", message: "User cancelled login")
                    return
                }
                // Successfully logged in:
                DispatchQueue.main.async {
                    completionHandler(true, nil)
                }
                
                Profile.loadCurrentProfile { (profile, error) in
                    UdacityAPIClient.Auth.firstName = Profile.current?.name ?? ""
                }
            }
        }
    }
    
    func setLogginIn(_ logginIn : Bool) {
        if logginIn {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        
        // Disable login's view while activityIndiciator is spinnibg:
        self.emailTextField.isEnabled = !logginIn
        self.passwordTextField.isEnabled = !logginIn
        self.loginButton.isEnabled = !logginIn
        self.loginViaWebsiteButton.isEnabled = !logginIn
    }
}

/*
 Key Delegate & Datasource Q:
 What should a UITableView ask its delegate & datasource?
 UITableViewDelegate    UITableViewDataSource
 Responses to User Events    Access to Data and Cells

 Think of delegates as being associated with events and the data source as being associated with data.

 The table uses its delegate protocol to ask event questions like these.
     → What should happen when a button in a cell is tapped?
     → What should be the response to cell selection?
     → How should I respond when a user begins edditing a row?
     → What should happen when a cell is deselected?

 The table uses its data source protocol to ask a data questions like these.
     → How many rows do I have?
     → How many sections do I have?
     → What are the titles for the sections?
     → What is the cell view for each row?

 */
