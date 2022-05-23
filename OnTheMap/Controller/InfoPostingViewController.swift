//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/13/22.
//

import Foundation
import UIKit
import MapKit

class InfoPostingViewController: UIViewController {
    
    @IBOutlet weak var geocodingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    
    var updateUserInformation = AddUserRequest()
    
    @IBAction func findLocation(_ sender: UIButton) {
        setLogginIn(true)
        getCoordinate(addressString: self.locationTextField.text ?? "",
                completionHandler: handleFindLocationResponse(locationCoord:error:))
    }
    
    @IBAction func returnToTabbedView(_ sender: UIBarButtonItem) {
        setLogginIn(false)
        dismiss(animated: true, completion: nil)
    }
    
    //  Getting a coordinate from an address string:
    func getCoordinate(addressString : String, completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func handleFindLocationResponse(locationCoord: CLLocationCoordinate2D, error: Error?) {
        setLogginIn(false)
        if error == nil {
            updateUserInformation.mapString = self.locationTextField.text ?? ""
            updateUserInformation.mediaURL = self.linkTextField.text ?? ""
            updateUserInformation.latitude = locationCoord.latitude
            updateUserInformation.longitude = locationCoord.longitude
            
            var controller: FindLocationViewController
            
            controller = storyboard?.instantiateViewController(withIdentifier: "geocodeUser") as! FindLocationViewController
            
            controller.locationName = self.locationTextField.text ?? ""
            controller.lat = locationCoord.latitude
            controller.long = locationCoord.longitude
            
            present(controller, animated: true, completion: nil)
            //self.performSegue(withIdentifier: "geocodeUser", sender: nil)
        } else {
            self.handleFailureAlert(title: "Geocoding Failed", message: error?.localizedDescription ?? "Unable to Find The Location.")
        }
    }
    
//    func handlePostingUserResponse(success: Bool, error: Error?) {
//        setLogginIn(false)
//        if success {
//            self.performSegue(withIdentifier: "geocodeUser", sender: nil)
//        }
//        else {
//            self.handleFailureAlert(title: "Posting Failed", message: error?.localizedDescription ?? "Unable to Post User Information.")
//        }
//    }
    
    func setLogginIn(_ logginIn : Bool) {
        if logginIn {
            self.geocodingActivityIndicator.startAnimating()
        } else {
            self.geocodingActivityIndicator.stopAnimating()
        }
    }
    
}
