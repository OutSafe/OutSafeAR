//
//  SetupViewController.swift
//  ARKit+CoreLocation
//
//  Created by Bobby Ren on 4/15/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import MapKit

class SetupViewController: UIViewController {

    var sessionId: String!
    
    @IBOutlet weak var mapView: MKMapView!
    // Data
    var annotations: [String: MKAnnotation] = [String:MKAnnotation]()
    let locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
    }

    var first: Bool = true
    func centerMapOnLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
//    func addAnnotation() {
//        guard let lat = event.lat, let lon = event.lon else { return }
//        if let oldAnnotation = annotations[event.id] {
//            mapView.removeAnnotations([oldAnnotation])
//        }
//
//        let annotation = MKPointAnnotation()
//        let coordinate = CLLocationCoordinate2DMake(lat, lon)
//        annotation.coordinate = coordinate
//        annotation.title = event.name
//        annotation.subtitle = event.locationString
//        mapView.addAnnotation(annotation)
//
//        annotations[event.id] = annotation
//    }
}

extension SetupViewController: LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation) {
        if first, let location = locationManager.currentLocation {
            centerMapOnLocation(location: location)
        }
    }
    
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationDirection) {
        
    }
    
    
}
extension SetupViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if first, let location = locationManager.currentLocation {
            centerMapOnLocation(location: location)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("mapview: region changed ")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        print("mapview: user location changed to \(location)")
        if first {
            first = false
            centerMapOnLocation(location: location)
        }
    }

//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        guard let selectedAnnotation = view.annotation else { return }
//        var selectedId: String?
//        for (eventId, annotation) in annotations {
//            if annotation.title! == selectedAnnotation.title! && annotation.coordinate.latitude == selectedAnnotation.coordinate.latitude && annotation.coordinate.longitude == selectedAnnotation.coordinate.longitude {
//                selectedId = eventId
//                break
//            }
//        }
//    }
//    
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//    }
}
