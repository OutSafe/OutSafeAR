//
//  VenueService.swift
//  ARKit+CoreLocation
//
//  Created by Bobby Ren on 4/14/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit

enum ExitType {
    case saferoom
    case door
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
    let label: String?
}

struct Exit: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    let type: String
}

struct Event: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    let status: Int
    let eventType: String
}

class VenueService: NSObject {
    class func getBuilding(completion: @escaping ((_ pins: [Pinnable])->Void)) {
        let service = APIService()
        service.cloudFunction(id: "6", functionName: "landmark", method: "GET", params: nil) { (result, error) in
            print("Result \(result) error \(error)")
            if let results = result as? [String: [String: Any]] {
                var pins: [Pinnable] = []
                for (id, dict) in results {
                    if let pin = process(id: id, dict: dict) {
                        pins.append(pin)
                    }
                }
                print("Pins: \(pins)")
                completion(pins)
            } else if let error = error {
                print("Invalid building specs")
            }
        }
    }
    
    class func process(id: String, dict: [String: Any]) -> Pinnable? {
//        guard let latString = dict["lat"] as? String, let lat = Double(latString) else { return nil }
//        guard let lonString = dict["lon"] as? String, let lon = Double(lonString) else { return nil }
//        guard let elString = dict["el"] as? String, let el = Double(elString) else { return nil }
        guard let lat = dict["lat"] as? Double else { print("Process failed at lat"); return nil }
        guard let lon = dict["lon"] as? Double else { print("Process failed at lon");return nil }
        guard let el = dict["el"] as? Double else { print("Process failed at el"); return nil }
        let label = dict["label"] as? String
        let exitType = dict["type"] as? String
        let eventType = dict["eventType"] as? String
        
        if let eventType = eventType {
            return Event(id: id, lat: lat, lon: lon, el: el, status: 1, eventType: eventType)
        } else if let exitType = exitType {
            return Exit(id: id, lat: lat, lon: lon, el: el, type: exitType)
        } else {
            return Landmark(id: id, lat: lat, lon: lon, el: el, label: label)
        }
    }
}
