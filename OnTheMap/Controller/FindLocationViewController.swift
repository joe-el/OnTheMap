//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/22/22.
//

import Foundation
import UIKit
import MapKit

class FindLocationViewController: UIViewController {
    
    //MARK: Properties
    
    let segueToTabView = LoginViewController()
    var locationName: String!
    var webLink: String!
    var lat: Double!
    var long: Double!
    var usersLocation: CLLocation!
    
    //MARK: Outlets
    
    @IBOutlet weak var findLocationMapView: MKMapView!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the starting coordinates of the map view to the user chosen location:
        usersLocation = CLLocation(latitude: lat, longitude: long)
        // Calls the helper method to zoom into usersLocation on startup:
        findLocationMapView.centerToLocation(usersLocation)
        
        // Pin object plotting the user location:
        let pinLocation = PinLocation(locationName: locationName, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        // Add pinLocation as an annotation to the map view:
        findLocationMapView.addAnnotation(pinLocation)
    }
    
    //MARK: Actions
    
    // Tapping the “Finish” button will post the location and link to the server:
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        if UdacityAPIClient.Auth.pinAlreadyPosted == false {
            UdacityAPIClient.postUserInformation(mapString: locationName, mediaURL: webLink, mapCoord: usersLocation, completionHandler: handleFinishResponse(success:error:))
        } else {
            UdacityAPIClient.updateUserInformation(mapString: locationName, mediaURL: webLink, mapCoord: usersLocation, completionHandler: handleFinishResponse(success:error:))
        }
    }
    
    // Dismiss current view then go back to Information Posting view:
    @IBAction func backToAddLocation(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Helper Methods
    
    // Either dismiss the map view if posting was successful or show an alert with error message:
    func handleFinishResponse(success: Bool, error: Error?) {
        // Return back to Map and Table Tabbed View:
        if success {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "mainView") else {
                return dismiss(animated: true, completion: nil)
            }
            // need to change the presentation style, modalPresentationStyle:
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            present(vc, animated: true)
            //segueToTabView.performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            self.handleFailureAlert(title: "Posting Failed", message: error?.localizedDescription ?? "Unable to Post User Information.")
        }
    }
    
}

private extension MKMapView {
    
    //MARK: MKMapView Extension
    
    // Specify the rectangular region to display and getting a zoom level:
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
}
