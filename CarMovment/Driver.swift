//
//  Driver.swift
//  Yamam
//
//  Created by sameh on 5/31/18.
//  Copyright © 2018 soleek. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

class Driver:NSObject
{
    static func == (lhs: Driver, rhs: Driver) -> Bool
    {
        return lhs.id == rhs.id
    }
    
    var id:Int
    var name:String
    var locations:[CLLocationCoordinate2D]
    var newLocations:[CLLocationCoordinate2D]?
    var animationInterval:CFTimeInterval = 0
    var timer:Timer?
    
    var marker:GMSMarker =
    {
        let marker = GMSMarker()
        marker.icon = #imageLiteral(resourceName: "car")
        return marker
    }()
    
    var timerClosure:((Timer) -> Swift.Void)?
    {
        didSet
        {
            guard let timerClosure = timerClosure else { return }
            timer?.invalidate()
            timer = nil 
            timer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true, block:timerClosure)
        }
    }
    enum CodingKeys:String,CodingKey
    {
        case id,name,locations,state
    }
    
    init(id: Int,name:String, locations: [CLLocationCoordinate2D], newLocations: [CLLocationCoordinate2D]?)
    {
        self.id = id
        self.locations = locations
        self.newLocations = newLocations
        self.name = name
    }

    init(id:Int,name:String)
    {
        self.id = id
        self.name = name
        let gpx = GPXParser(fileNames: ["track"])
        locations =  gpx.getPolygons()
    }
    
}
