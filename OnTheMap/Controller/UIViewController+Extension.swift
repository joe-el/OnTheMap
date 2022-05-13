//
//  UIViewController+Extension.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/12/22.
//

import Foundation
import UIKit

extension UIViewController {
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        //dismiss(animated: true, completion: nil)
        UdacityAPIClient.logout { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                print(error!)
            }
        }
    }
    
}
