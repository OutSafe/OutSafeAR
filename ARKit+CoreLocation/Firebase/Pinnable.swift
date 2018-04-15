//
//  Pinnable.swift
//  ARKit+CoreLocation
//
//  Created by Bobby Ren on 4/15/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit
import MapKit

enum PinnableType: String {
    // landmarks
    case landmark
    
    // doors
    case exit
    
    // events
    case event
}

enum LandmarkType: String {
    case corner
    case other
}

enum ExitType: String {
    case saferoom
    case door
}

enum EventType: String {
    case fire
    case shooter
}

protocol Pinnable {
    var id: String { get }
    var lat: Double { get }
    var lon: Double { get }
    var el: Double { get }
}

struct Landmark: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    var landmarkType: LandmarkType
    let label: String?
}

struct Exit: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    let status: Int
    let exitType: ExitType
}

struct Event: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    let eventType: EventType
}

class PinnableAnnotation: MKPointAnnotation {
    var pin: Pinnable!
    var image: UIImage? {
        if let pin = pin as? Landmark {
            return UIImage(named: "iconPin")
        } else if let pin = pin as? Exit {
            return UIImage(named: "iconDoor")
        } else if let pin = pin as? Event {
            if pin.eventType == .fire {
                return UIImage(named: "iconFire")
            } else {
                return UIImage(named: "iconGun")
            }
        }
        return nil
    }
}

extension UIImage {
    func resized(newSize: CGSize) -> UIImage? {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
