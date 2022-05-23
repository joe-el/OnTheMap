//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/13/22.
//

import Foundation
import UIKit
import MapKit

class MapTabViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    /*
     The map. See the setup in the Storyboard file. Note particularly that the view controller
     is set up as the map view's delegate.
     */
    @IBOutlet weak var mapView: MKMapView!
    
    /*
     We will create an MKPointAnnotation for each stored struct properties in "locations". The
     point annotations will be stored in this array, and then provided to the map view.
     */
    var annotations = [MKPointAnnotation]()
    
    // MARK: Load View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadStudentData()
    }
    
    // MARK: - MKMapViewDelegate

    /*
     Here we create a view with a "right callout accessory view". You might choose to look into other
     decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
     method in TableViewDataSource.
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    /*
     This delegate method is implemented to respond to taps. It opens the system browser
     to the URL specified in the annotationViews subtitle property.
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                openWebsiteLink(urlString: toOpen)
            }
        }
    }
//    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//        if control == annotationView.rightCalloutAccessoryView {
//            let app = UIApplication.sharedApplication()
//            app.openURL(NSURL(string: annotationView.annotation.subtitle))
//        }
//    }

    // MARK: Students Data
    
    /*
     Downloads the 100 most recent locations posted by students, saved as an array of structs,
     appended on to annotations, and then provided to mapView.
     */
    func downloadStudentData() {
        UdacityAPIClient.getStudentInformation() { studentsInfo, error in
            if error == nil {
                StudentInformationModel.studentLocation = studentsInfo
                self.createAnnotations()
                // When the array is complete, we add the annotations to the map.
                self.mapView.addAnnotations(self.annotations)
            } else {
                self.handleFailureAlert(title: "Download Failed", message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func createAnnotations() {
        /*
         The "locations" array is an array of struct that are decoded from the JSON
         data that you can download from UdacityAPI.
         */
        let locations = StudentInformationModel.studentLocation //hardCodedLocationData()
        
        /*
         The "locations" array is loaded with the student location data below. We are using the dictionaries
         to create map annotations. This would be more stylish if the dictionaries were being
         used to create custom structs.
         */
        for dictionary in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(dictionary.latitude)
            let long = CLLocationDegrees(dictionary.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
    }
    
}
