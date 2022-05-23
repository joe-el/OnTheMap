//
//  OpenWebsiteViewController.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/19/22.
//

import Foundation
import UIKit

extension UIViewController {
    
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
    
}
