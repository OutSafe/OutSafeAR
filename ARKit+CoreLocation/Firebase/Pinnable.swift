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
    var image: UIImage? { get }
}

struct Landmark: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    var landmarkType: LandmarkType
    let label: String?
    
    var image: UIImage? {
        if let label = label, !label.isEmpty {
            return UIImage(named: "iconLandmark")
        }
        return UIImage(named: "iconPin")
    }
}

struct Exit: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    let status: Int
    let exitType: ExitType
    var image: UIImage? {
        return UIImage(named: "iconDoor")
    }
}

struct Event: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    let eventType: EventType
    var image: UIImage? {
        if eventType == .fire {
            return UIImage(named: "iconFire")
        } else {
            return UIImage(named: "iconGun")
        }
    }
}

class PinnableAnnotation: MKPointAnnotation {
    var pin: Pinnable!
    var image: UIImage? {
        return pin.image
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
