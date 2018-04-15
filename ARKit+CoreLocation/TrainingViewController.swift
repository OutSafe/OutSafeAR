


//
//  ViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit
import SceneKit 
import MapKit
import CocoaLumberjack

@available(iOS 11.0, *)
class TrainingViewController: UIViewController, MKMapViewDelegate, SceneLocationViewDelegate {
    let sceneLocationView = SceneLocationView()
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    var annotations: [PinnableAnnotation] = [PinnableAnnotation]()

    var updateUserLocationTimer: Timer?
    
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView = false
    
    var centerMapOnUserLocation: Bool = true
    
    ///Whether to display some debugging data
    ///This currently displays the coordinate of the best location estimate
    ///The initial value is respected
    var displayDebugging = false
    
    var infoLabel = UILabel()
    
    var updateInfoLabelTimer: Timer?
    
    var adjustNorthByTappingSidesOfScreen = true
    
    // timers
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var buttonSafe: UIButton!
    var safeTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.font = UIFont.systemFont(ofSize: 10)
        infoLabel.textAlignment = .left
        infoLabel.textColor = UIColor.white
        infoLabel.numberOfLines = 0
        sceneLocationView.addSubview(infoLabel)
        
        infoLabel.isHidden = true
        
        updateInfoLabelTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(TrainingViewController.updateInfoLabel),
            userInfo: nil,
            repeats: true)
        
        //Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
//        sceneLocationView.orientToTrueNorth = false
        
//        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        
        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
        }

        self.view.insertSubview(self.sceneLocationView, belowSubview: labelTimer)
        
        // CODEFEST 2018
        refresh {
            
            if self.showMapView {
                self.toggleMap()
            }
        }
        
        startTimer()
    }
    
    fileprivate func toggleMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 0.8
        view.addSubview(mapView)
        
        updateUserLocationTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(TrainingViewController.updateUserLocation),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DDLogDebug("run")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DDLogDebug("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: labelTimer.frame.size.height,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height - labelTimer.frame.size.height - buttonSafe.frame.size.height)
        
        infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
        
        if showMapView {
            infoLabel.frame.origin.y = (self.view.frame.size.height / 2) - infoLabel.frame.size.height
        } else {
            infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
        }
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
    @IBAction func didClickSafe(_ sender: Any) {
        stopTimer()
        safeTimer = nil
    }
    
    fileprivate func startTimer() {
        guard safeTimer == nil else { return }
        let startTime = Date()
        safeTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            let timeInterval = Date().timeIntervalSince(startTime)
            let min = Int(timeInterval / 60)
            let sec = Int(timeInterval - Double(min * 60))
            
            let ms = Int((Double(timeInterval) - Double(min * 60) - Double(sec)) * 100)
            self.labelTimer.text = "\(min)m \(sec)s \(ms)ms"
        })
    }
    
    fileprivate func stopTimer() {
        safeTimer?.invalidate()
        safeTimer = nil
        buttonSafe.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @objc func updateUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                
                if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
                    let position = self.sceneLocationView.currentScenePosition() {
                    DDLogDebug("")
                    DDLogDebug("Fetch current location")
                    DDLogDebug("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
                    DDLogDebug("current position: \(position)")
                    
                    let translation = bestEstimate.translatedLocation(to: position)
                    
                    DDLogDebug("translation: \(translation)")
                    DDLogDebug("translated location: \(currentLocation)")
                    DDLogDebug("")
                }
                
                if self.userAnnotation == nil {
                    self.userAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.userAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
            
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                    })
                }
                
                if self.displayDebugging {
                    let bestLocationEstimate = self.sceneLocationView.bestLocationEstimate()
                    
                    if bestLocationEstimate != nil {
                        if self.locationEstimateAnnotation == nil {
                            self.locationEstimateAnnotation = MKPointAnnotation()
                            self.mapView.addAnnotation(self.locationEstimateAnnotation!)
                        }
                        
                        self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
                    } else {
                        if self.locationEstimateAnnotation != nil {
                            self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
                            self.locationEstimateAnnotation = nil
                        }
                    }
                }
            }
        }
    }
    
    @objc func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition() {
            infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }
        
        if let eulerAngles = sceneLocationView.currentEulerAngles() {
            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }
        
        if let heading = sceneLocationView.locationManager.heading,
            let accuracy = sceneLocationView.locationManager.headingAccuracy {
            infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
        }
        
        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil {
                if (mapView == touch.view! ||
                    mapView.recursiveSubviews().contains(touch.view!)) {
                    centerMapOnUserLocation = false
                } else {
                    
                    let location = touch.location(in: self.view)

                    if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
                        print("left side of the screen")
                        sceneLocationView.moveSceneHeadingAntiClockwise()
                    } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
                        print("right side of the screen")
                        sceneLocationView.moveSceneHeadingClockwise()
                    } else {
                        let image = UIImage(named: "pin")!
                        let annotationNode = LocationAnnotationNode(location: nil, image: image)
                        annotationNode.scaleRelativeToDistance = true
                        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
                    }
                }
            }
        }
    }
    
    //MARK: MKMapViewDelegate
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        }
//
//        if let pointAnnotation = annotation as? MKPointAnnotation {
//            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
//
//            if pointAnnotation == self.userAnnotation {
//                marker.displayPriority = .required
//                marker.glyphImage = UIImage(named: "user")
//            } else {
//                marker.displayPriority = .required
//                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
//                marker.glyphImage = UIImage(named: "compass")
//            }
//
//            return marker
//        }
//
//        return nil
//    }
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

    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
    func sceneLocationViewDidUpdateHeading(heading: CLLocationDirection) {
//        mapView.camera.heading = heading
//        mapView.setCamera(mapView.camera, animated: true)
    }
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}

extension TrainingViewController {
    func refresh(completion:@escaping (()->Void)) {
        for node in sceneLocationView.locationNodes {
            sceneLocationView.removeLocationNode(locationNode: node)
        }
        annotations.removeAll()

        VenueService.getPins(type: .landmark, completion: { (resultDict) in
            DispatchQueue.main.async {
                for (id, pin) in resultDict {
                    self.addLandmark(pin: pin)
                    self.addAnnotation(pin: pin)
                }
                completion()
            }
        })
        
        VenueService.getPins(type: .exit, completion: { (resultDict) in
            DispatchQueue.main.async {
                for (id, pin) in resultDict {
                    self.addLandmark(pin: pin)
                    self.addAnnotation(pin: pin)
                }
                completion()
            }
        })
        
        VenueService.getPins(type: .event, completion: { (resultDict) in
            DispatchQueue.main.async {
                for (id, pin) in resultDict {
                    self.addLandmark(pin: pin)
                    self.addAnnotation(pin: pin)
                }
                completion()
            }
        })
    }
    
    func addLandmark(pin: Pinnable) {
        let lat = pin.lat
        let lon = pin.lon
        let altitude = sceneLocationView.currentLocation()?.altitude ?? 22.0 // pin.el // basically by default
        let label: String
        if let landmark = pin as? Landmark, let text = landmark.label {
            label = text
        } else {
            label = ""
        }
        
        print("Adding pin at \(lat) \(lon) \(altitude) label: \(label)")
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: altitude)
        let pinImage = pin.image ?? UIImage(named: "pin")!
        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage.resized(newSize: CGSize(width: 50, height: 50))!)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
    }
    
    func addAnnotation(pin: Pinnable) {
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
        
        annotations.append(annotation)
    }
}
