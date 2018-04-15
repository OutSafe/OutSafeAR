//
//  Pinnable.swift
//  ARKit+CoreLocation
//
//  Created by Bobby Ren on 4/15/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit

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
    let label: String?
}

struct Exit: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    let status: Int
    let type: ExitType
}

struct Event: Pinnable {
    var id: String
    var lat: Double
    var lon: Double
    var el: Double
    let eventType: EventType
}
