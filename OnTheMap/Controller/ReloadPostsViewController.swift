//
//  ReloadPostsViewController.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/20/22.
//

import Foundation
import UIKit

extension UIViewController {
    
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
    
}
