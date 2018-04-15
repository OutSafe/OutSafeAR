//
//  VenueService.swift
//  ARKit+CoreLocation
//
//  Created by Bobby Ren on 4/14/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit

class VenueService: NSObject {
    static let shared = VenueService()
    var sessionId: String?
    
    class func getPins(type: PinnableType, completion: @escaping ((_ pins: [String: Pinnable])->Void)) {
        guard let sessionId = shared.sessionId else { return }
        let service = APIService()
        service.cloudFunction(id: sessionId, functionName: type.rawValue, method: "GET", params: nil) { (result, error) in
            print("Result \(result) error \(error)")
            if let results = result as? [String: [String: Any]] {
                var pins: [String: Pinnable] = [:]
                for (id, dict) in results {
                    if let pin = process(id: id, dict: dict) {
                        pins[id] = pin
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
        guard let lat = dict["lat"] as? Double else { print("Process failed at lat"); return nil }
        guard let lon = dict["lon"] as? Double else { print("Process failed at lon");return nil }
        guard let el = dict["el"] as? Double else { print("Process failed at el"); return nil }
        let label = dict["label"] as? String
        if let exitType = dict["type"] as? String, let type = ExitType(rawValue: exitType) {
            let status = dict["status"] as? Int ?? 0
            return Exit(id: id, lat: lat, lon: lon, el: el, status: status, type: type)
        } else if let eventType = dict["eventType"] as? String, let type = EventType(rawValue: eventType) {
            return Event(id: id, lat: lat, lon: lon, el: el, eventType: type)
        } else {
            return Landmark(id: id, lat: lat, lon: lon, el: el, label: label)
        }
    }
}
