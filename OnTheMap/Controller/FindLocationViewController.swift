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
    
    var locationName: String!
    var lat: Double!
    var long: Double!
    var usersLocation: CLLocation!
    let usersInfo = AddUserRequest()
    
    //MARK: Outlets
    
    @IBOutlet weak var findLocationMapView: MKMapView!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        
        usersLocation = CLLocation(latitude: lat, longitude: long)
        findLocationMapView.centerToLocation(usersLocation)
        
        let pinLocation = PinLocation(locationName: locationName, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        findLocationMapView.addAnnotation(pinLocation)
    }
    
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        UdacityAPIClient.postUserInformation(mapString: usersInfo.mapString, mediaURL: usersInfo.mediaURL, mapCoord: usersLocation, completionHandler: handleFinishResponse(success:error:))
    }
    
    func handleFinishResponse(success: Bool, error: Error?) {
        if success {
            dismiss(animated: true, completion: nil)
        } else {
            self.handleFailureAlert(title: "Posting Failed", message: error?.localizedDescription ?? "Unable to Post User Information.")
        }
    }
    
}

private extension MKMapView {
    
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
}
