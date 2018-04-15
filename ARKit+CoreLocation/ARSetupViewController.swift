//
//  ARSetupViewController.swift
//  OutSafeAR
//
//  Created by Bobby Ren on 4/15/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import MapKit
import SceneKit
import CocoaLumberjack

class ARSetupViewController: SetupViewController {
    let sceneLocationView = SceneLocationView()
    var showMap: Bool = false {
        didSet {
            if showMap {
                constraintMapTopOffset.constant = 0
                sceneLocationView.pause()
                mapView.alpha = 1
            } else {
                constraintMapTopOffset.constant = self.view.frame.size.height * 2 / 3.0
                sceneLocationView.run()
                mapView.alpha = 0.3
            }
        }
    }
    
    @IBOutlet weak var buttonMap: UIButton!
    @IBOutlet weak var constraintMapTopOffset: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self

        self.view.insertSubview(sceneLocationView, belowSubview: mapView)
        showMap = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    @IBAction func didClickMap(_ sender: Any) {
        showMap = !showMap
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
    }
}
extension ARSetupViewController: SceneLocationViewDelegate {
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
    func sceneLocationViewDidUpdateHeading(heading: CLLocationDirection) {
        mapView.camera.heading = heading
        mapView.setCamera(mapView.camera, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
