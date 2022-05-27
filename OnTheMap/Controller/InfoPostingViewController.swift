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
    
    //MARK: Outlets
    
    @IBOutlet weak var geocodingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    
    //MARK: - Actions:
    
    @IBAction func findLocation(_ sender: UIButton) {
        setLogginIn(true)
        getCoordinate(addressString: self.locationTextField.text ?? "",
                completionHandler: handleFindLocationResponse(locationCoord:error:))
    }
    
    @IBAction func returnToTabbedView(_ sender: UIBarButtonItem) {
        //setLogginIn(false)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helper Methods:
    
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
           let  enteredLocationController = storyboard?.instantiateViewController(withIdentifier: "geocodeUser") as! FindLocationViewController
            
            enteredLocationController.locationName = self.locationTextField.text ?? ""
            enteredLocationController.webLink =  self.linkTextField.text ?? ""
            enteredLocationController.lat = locationCoord.latitude
            enteredLocationController.long = locationCoord.longitude
            
            present(enteredLocationController, animated: true, completion: nil)
        } else {
            handleFailureAlert(title: "Geocoding Failed", message: error?.localizedDescription ?? "Unable to Find The Location.")
        }
    }
    
    func setLogginIn(_ logginIn : Bool) {
        if logginIn {
            self.geocodingActivityIndicator.startAnimating()
        } else {
            self.geocodingActivityIndicator.stopAnimating()
        }
    }
    
}
