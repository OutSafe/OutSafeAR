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
    @IBOutlet weak var buttonStart: UIButton!
    
    // Data
    var annotations: [MKAnnotation] = [MKAnnotation]()
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
    
    func refresh(completion:@escaping (()->Void)) {
        mapView.removeAnnotations(annotations)
        VenueService.getBuilding { (pins) in
            DispatchQueue.main.async {
                for pin in pins {
                    self.addAnnotation(pin: pin)
                }
                completion()
            }
        }
    }

    func addAnnotation(pin: Pinnable) {
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2DMake(pin.lat, pin.lon)
        annotation.coordinate = coordinate
        if let title = (pin as? Landmark)?.label {
            annotation.title = title
        }
        if let type = (pin as? Event)?.eventType {
            annotation.subtitle = type
        } else if let type = (pin as? Exit)?.type {
            annotation.subtitle = type
        }
        mapView.addAnnotation(annotation)
    }
}

extension SetupViewController: LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation) {
        if first, let location = locationManager.currentLocation {
            centerMapOnLocation(location: location)
        }
        
        if location.horizontalAccuracy < 15 {
            print("Location accuracy: ready (\(location.horizontalAccuracy))")
            buttonStart.isEnabled = true
            buttonStart.alpha = 1
        } else {
            print("Location accuracy: not ready (\(location.horizontalAccuracy))")
            buttonStart.isEnabled = false
            buttonStart.alpha = 0.5
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
//        for annotation in annotations {
//            if annotation.title! == selectedAnnotation.title! && annotation.coordinate.latitude == selectedAnnotation.coordinate.latitude && annotation.coordinate.longitude == selectedAnnotation.coordinate.longitude {
//                break
//            }
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//    }
}
