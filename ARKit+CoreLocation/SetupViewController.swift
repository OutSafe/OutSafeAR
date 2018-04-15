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
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonBang: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!

    var locationIsAccurate: Bool {
        return currentAccuracy < 15
    }
    var currentAccuracy: Double = 0 {
        didSet {
            if locationIsAccurate {
//                print("Location accuracy: ready (\(currentAccuracy))")
                buttonPlay.alpha = 1
            } else {
//                print("Location accuracy: not ready (\(currentAccuracy))")
                buttonPlay.alpha = 0.5
            }
        }
    }
    
    // Data
    var annotations: [String: PinnableAnnotation] = [String: PinnableAnnotation]()
    let locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOnNotification), name: Notification.Name.RemoteNotificationReceived, object: nil)
    }

    var first: Bool = true
    func centerMapOnLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func refreshOnNotification() {
        print("Calling refreshOnNotification")
        refresh {
            
        }
    }
    
    func refresh(completion:@escaping (()->Void)) {
        for (key, value) in annotations {
            mapView.removeAnnotation(value)
            annotations[key] = nil
        }
        VenueService.getPins(type: .landmark, completion: { (resultDict) in
            DispatchQueue.main.async {
                for (id, pin) in resultDict {
                    self.addAnnotation(id: id, pin: pin)
                }
                completion()
            }
        })
        
        VenueService.getPins(type: .exit, completion: { (resultDict) in
            DispatchQueue.main.async {
                for (id, pin) in resultDict {
                    self.addAnnotation(id: id, pin: pin)
                }
                completion()
            }
        })

        VenueService.getPins(type: .event, completion: { (resultDict) in
            DispatchQueue.main.async {
                for (id, pin) in resultDict {
                    self.addAnnotation(id: id, pin: pin)
                }
                completion()
            }
        })
    }

    func addAnnotation(id: String, pin: Pinnable) {
        let annotation = PinnableAnnotation()
        annotation.pin = pin
        
        let coordinate = CLLocationCoordinate2DMake(pin.lat, pin.lon)
        annotation.coordinate = coordinate
        if let title = (pin as? Landmark)?.label {
            annotation.title = title
        }
        if let type = (pin as? Event)?.eventType {
            annotation.subtitle = type.rawValue
        } else if let type = (pin as? Exit)?.exitType {
            annotation.subtitle = type.rawValue
        }
        mapView.addAnnotation(annotation)
        
        annotations[id] = annotation
    }
    
    @IBAction func didClickButton(_ sender: UIButton) {
        if locationIsAccurate {
            showOptions(for: sender)
        } else {
            let alert = UIAlertController(title: "Warning: Location inaccurate", message: "Your location accuracy is currently at \(Int(currentAccuracy)). Accuracy below 15m will help with a better experience. Continue?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Wait", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                self.showOptions(for: sender)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func showOptions(for button: UIButton) {
        if button == buttonPlay {
            goToTraining()
        } else if button == buttonPlus {
            goToAddPin()
        } else if button == buttonBang {
            goToAddIncident()
        }
    }

    fileprivate func goToTraining() {
        performSegue(withIdentifier: "toARView", sender: nil)
    }
    
    fileprivate func goToAddPin() {
        let alert = UIAlertController(title: "Please select landmark type:", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Exit (Door)", style: .default, handler: { (action) in
            self.addExit(type: .door)
        }))
        alert.addAction(UIAlertAction(title: "Saferoom", style: .default, handler: { (action) in
            self.addExit(type: .saferoom)
        }))
        alert.addAction(UIAlertAction(title: "Corner", style: .default, handler: { (action) in
            self.addLandmark(label: nil)
        }))
        alert.addAction(UIAlertAction(title: "Other", style: .default, handler: { (action) in
            let alert = UIAlertController(title: "Please label the landmark:", message: "ex: stage, screen, restroom...", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (textField) in
                textField.placeholder = " "
            }
            
            alert.addAction(UIAlertAction(title: "Save", style: .default) { (alertAction) in
                let textField = alert.textFields![0] as UITextField
                print(textField.text)
                self.addLandmark(label: textField.text)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in
            })
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
        }))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func goToAddIncident() {
        let alert = UIAlertController(title: "Please select event type:", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Fire", style: .default, handler: { (action) in
            self.addEvent(type: .fire)
        }))
        alert.addAction(UIAlertAction(title: "Shooter", style: .default, handler: { (action) in
            self.addEvent(type: .shooter)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension SetupViewController: LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation) {
        if first, let location = locationManager.currentLocation {
            centerMapOnLocation(location: location)
        }
        
        currentAccuracy = location.horizontalAccuracy
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
            refresh {
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.canShowCallout = true
        
        if let pinAnnotation = annotation as? PinnableAnnotation {
            annotationView.image = pinAnnotation.image?.resized(newSize: CGSize(width: 20, height: 20))
        }
        return annotationView
    }
}

// MARK: - Setup
extension SetupViewController {
    fileprivate func addLandmark(label: String?) {
        guard let location = locationManager.currentLocation else { return }
        
        let params: [String: Any] = ["lat": location.coordinate.latitude,
                                     "lon": location.coordinate.longitude,
                                     "el": location.altitude,
                                     "label": label ?? "corner"
                                    ]
        sendData(params: params, name: "landmark")
    }
    
    fileprivate func addExit(type: ExitType) {
        guard let location = locationManager.currentLocation else { return }
        
        let params: [String: Any] = ["lat": location.coordinate.latitude,
                                     "lon": location.coordinate.longitude,
                                     "el": location.altitude,
                                     "type": type.rawValue
        ]
        sendData(params: params, name: "exit")
    }

    fileprivate func addEvent(type: EventType) {
        guard let location = locationManager.currentLocation else { return }
        
        let params: [String: Any] = ["lat": location.coordinate.latitude,
                                     "lon": location.coordinate.longitude,
                                     "el": location.altitude,
                                     "eventType": type.rawValue
        ]
        sendData(params: params, name: "event")
    }
    
    func sendData(params:[String:Any], name: String){
        
        guard let sessionId = VenueService.shared.sessionId else { return }
        let service = APIService()
        
        service.cloudFunction(id: sessionId, functionName: name, params: params) { (result, error) in
            DispatchQueue.main.async {
                if let successfulResult = result as? [String:Any]{
                    print(successfulResult)
                    let title = "Saved!"
                    let lon = successfulResult["lon"]!
                    let lat = successfulResult["lat"]!
                    let message: String
                    if let placeLabel = successfulResult["label"]{
                        message = "\(placeLabel): \n\(lat),\n\(lon)"
                    } else if let placeType = successfulResult["type"]{
                        message = "\(placeType): \n\(lat),\n\(lon)"
                    } else if let eventType = successfulResult["eventType"] {
                        message = "\(eventType): \n\(lat),\n\(lon)"
                    } else {
                        message = ""
                    }
                    self.feedback(title: title, message: message)
                    
                    self.refresh {
                        
                    }
                }
                else{
                    if let failedResult = error{
                        let title = "Error!"
                        let message = "Please try again"
                        print(failedResult)
                        self.feedback(title: title, message: message)
                    }
                }
            }
        }
    }
    
    
    func feedback(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(action)
        
        self.present(alert, animated:true, completion: nil)
        
    }
}
