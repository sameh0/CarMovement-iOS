//
//  DriverManager.swift
//  CarMovment
//
//  Created by Sameh sayed on 7/11/18.
//  Copyright © 2018 Sameh sayed. All rights reserved.
//
//
import Foundation
import CoreLocation
import GoogleMaps

class DriverManager:NSObject
{
    private var drivers = [Driver]()
    private var map:GMSMapView!
    
    //TODO create this as a sperate class that takes a driver/s and a map and animates it
    //This driver animations manager - takes array of drivers and a function to update them
    
    init(map:GMSMapView,drivers:[Driver])
    {
        super.init()
        self.map = map
        addDrivers(drivers)
    }
    
    func addDrivers(_ drivers:[Driver])
    {
        drivers.forEach
            {
                driver in
                
                let filtered = self.drivers.filter({ return $0 == driver })
                
                guard
                    filtered.count > 0
                    else
                {
                    //New Driver
                    self.drivers.append(driver)
                    animateDriver(driver)
                    return
                }
                
                updateExistingDriver(driver: filtered[0], locations: driver.locations)
        }
    }
    
    private func updateExistingDriver(driver:Driver,locations:[CLLocationCoordinate2D])
    {
        if driver.timer != nil // Driver in animation mode
        {
            driver.newLocations = locations
        }
        else
        {
            driver.locations = locations
            animateDriver(driver)
        }
    }
    
    private func animateDriver( _ driver:Driver)
    {
        let totalSeconds:Double = 400
        
        driver.marker.position = driver.locations.first!
        driver.marker.map = map
        driver.marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        driver.animationInterval = totalSeconds / Double(driver.locations.count) //makes the animation happens in 15 secs
        driver.timerClosure =
            {
                _ in
                
                //Call the function every fixed interval
                if driver.locations.count > 1
                {
                    self.driverAnimation(driver, cameraFollow: true)
                }
                else
                {
                    //New locations exists copy it to the current locations and empty it for the new upcoming new locations
                    if let newLocations = driver.newLocations
                    {
                        driver.locations = newLocations
                        self.driverAnimation(driver, cameraFollow: true)
                    }
                    else
                    {
                        //No new locations , no current : remove driver
                        self.removeDriver(driver: driver)
                    }
                }
        }
    }
    
    private func driverAnimation(_ driver:Driver,cameraFollow:Bool)
    {
        guard
            let firstLocation = driver.locations.first
            else
        {
            removeDriver(driver: driver)
            return
        }
        
        let secondLocation = driver.locations[1]
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(driver.animationInterval)
        
        let angle = getAngle(fromCoordinate: firstLocation, second: secondLocation)
        driver.marker.position = secondLocation
        driver.marker.rotation = angle * (180 / .pi)
        
        if cameraFollow
        {
            map.animate(to: GMSCameraPosition(target: secondLocation, zoom: 15, bearing: 0, viewingAngle: 0))
        }
        
        CATransaction.commit()
        
        driver.locations.removeFirst()
    }
    
    private func removeDriver(driver:Driver)
    {
        driver.timer?.invalidate()
        driver.timer = nil
        let driverIndex = drivers.index(of: driver)
        drivers.remove(at: driverIndex!)
    }
    
    private func getAngle(fromCoordinate first:CLLocationCoordinate2D,second:CLLocationCoordinate2D)->Double
    {
        let dLong = second.longitude - first.longitude
        let dLat = second.latitude - first.latitude
        let angle = (.pi * 0.5) - atan(dLat / dLong)
        
        if dLong > 0 { return angle }
        if dLong < 0 { return angle + .pi }
        if dLat < 0  { return .pi }
        
        return 0
    }
}
