//
//  ReloadPostsViewController.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/20/22.
//

import Foundation
import UIKit
import FBSDKLoginKit

extension UIViewController {
    
    //MARK: - Actions:
    @IBAction func reloadStudentPosts(_ sender: UIBarButtonItem) {
        UdacityAPIClient.getStudentInformation() { studentsInfo, error in
            if error == nil {
                StudentInformationModel.studentLocation = studentsInfo
                print("success at reload.")
            } else {
                self.handleFailureAlert(title: "Download Failed", message: error?.localizedDescription ?? "Unable to Reload Students Information.")
            }
        }
    }
    
    @IBAction func addStudentInformation(_ sender: UIBarButtonItem) {
        let userHadPosted = UdacityAPIClient.Auth.objectId != ""
        
        if userHadPosted {
            // Create the action buttons for the alert.
            let defaultAction = UIAlertAction(title: "Overwrite", style: .default) { (action) in
                // Respond to user selection of the action.
                self.handleAlertOverwriteResponse(userHadPosted: true)
                }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // Respond to user selection of the action—which to cancel the alert.
                }
               
            // Create and configure the alert controller.
            let postingAlert = UIAlertController(title: nil, message:  "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .alert)
            postingAlert.addAction(defaultAction)
            postingAlert.addAction(cancelAction)
                    
            present(postingAlert, animated: true, completion: nil)
        } else {
            handleAlertOverwriteResponse(userHadPosted: false)
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        UdacityAPIClient.logout { (success, error) in
            if success {
                // Access token available—user already logged in:
                let loginManager = LoginManager()
                
                if let _ = AccessToken.current {
                    // Perform logout:
                    loginManager.logOut()
                }
                
                // Instantiate the LoginViewController:
                guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginView") else {
                    return self.dismiss(animated: true, completion: nil)
                }
                // Changed the presentation and transition style of the viewController:
                loginVC.modalPresentationStyle = .fullScreen
                loginVC.modalTransitionStyle = .flipHorizontal
                self.present(loginVC, animated: true)
            } else {
                self.handleFailureAlert(title: "Logout Failed", message: error?.localizedDescription ?? "")
            }
        }
    }
    
    //MARK: Helper Methods
    func handleAlertOverwriteResponse(userHadPosted: Bool) {
        UdacityAPIClient.Auth.pinAlreadyPosted = userHadPosted
        self.performSegue(withIdentifier: "addLocation", sender: nil)
    }
    
    func openWebsiteLink(urlString: String?) {
        guard let urlString = urlString else {
            handleFailureAlert(title: "Failed to Open ", message: "No web address given.")
            return
        }
        
        let studentWebSite = URL(string: urlString)
        
        if let validURLString = studentWebSite {
            let validURL: Bool = UIApplication.shared.canOpenURL(validURLString)
            if validURL {
                UIApplication.shared.open(validURLString, options: [:], completionHandler: nil)
            } else {
                handleFailureAlert(title: "Failed to Open ", message: "Invalid web address.")
            }
        } else {
            handleFailureAlert(title: "Failed to Open ", message: "No web address given.")
        }
    }
    
    func handleFailureAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
}
