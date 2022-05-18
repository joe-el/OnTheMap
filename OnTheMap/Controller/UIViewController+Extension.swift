//
//  UIViewController+Extension.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/16/22.
//

import Foundation
import UIKit

extension UIViewController {
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        UdacityAPIClient.logout { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.handleFailureAlert(title: "Logout Failed", message: error?.localizedDescription ?? "")
            }
        }
    }
    
}
