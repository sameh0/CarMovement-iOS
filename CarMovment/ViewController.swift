//
//  ViewController.swift
//  CarMovment
//
//  Created by Sameh sayed on 7/11/18.
//  Copyright © 2018 Sameh sayed. All rights reserved.
//

import UIKit
import GoogleMaps


class ViewController: UIViewController {
    
    @IBOutlet weak var mapView:GMSMapView!
    
    var manager:DriverManager!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let driver = Driver(id: 0, name: "car1")
        manager = DriverManager(map: mapView,drivers:[driver])
        
    }
}
