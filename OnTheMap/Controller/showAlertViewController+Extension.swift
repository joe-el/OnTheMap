//
//  showAlertViewController+Extension.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/18/22.
//

import Foundation
import UIKit

extension UIViewController {
    func handleFailureAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
