//
//  ViewController.swift
//  DisplayDirectionDemo
//
//  Created by qingjiezhao on 7/16/15.
//  Copyright (c) 2015 qingjiezhao. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapView: MKMapView!
    var locationManager: CLLocationManager?
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
        mapView = MKMapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = .Standard
        mapView.frame = view.frame
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func provideDirections(){
        let destination = "Syracuse University, NY, USA"
        CLGeocoder().geocodeAddressString(destination, completionHandler: {(placemarks:[AnyObject]!,error:NSError!) in
        
            if error != nil {
                //handle error here perhaps by displaying an alert
            }else{
                let request = MKDirectionsRequest()
                request.setSource(MKMapItem.mapItemForCurrentLocation())
                
                //Convert the CoreLocation destination placemark to a MapKit placemark
                let placemark = placemarks[0] as! CLPlacemark
                let destinationCoordinates = placemark.location.coordinate
                //Get the placemark of the destination address
                let destination = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
                request.setDestination(MKMapItem(placemark: destination))
                
                //set transportation method to automobile
                request.transportType = .Automobile
                
                //get the directions
                let directions = MKDirections(request: request)
                directions.calculateDirectionsWithCompletionHandler{(response:MKDirectionsResponse!,error:NSError!) in
                
                    //Display the directions on the map apps
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    MKMapItem.openMapsWithItems([response.source, response.destination], launchOptions: launchOptions)
                
                }
            }
            
        })
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("The authorization status of location " + "services is changed to:")
        
        
        switch CLLocationManager.authorizationStatus() {
            case .Denied:
                println("Denied")
            case .NotDetermined:
                println("Not determined")
            case .Restricted:
                println("Restricted")
            default:
                println("Authorized")
                provideDirections()
            
        }
    }
    
    
    func displayAlertWithTitle(title:String,message:String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
    }
    
    //add the pin to the map and center the map around the pin
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Are location servers available on this device?
        
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
                case .Denied:
                displayAlertWithTitle("Not Determined", message: "Location serviers are not allowed for this app")
                case .NotDetermined:
                    locationManager = CLLocationManager()
                    if let manager = self.locationManager{
                        manager.delegate = self
                        manager.requestWhenInUseAuthorization()
                    }
                case .Restricted:
                    displayAlertWithTitle("Restricted",
                        message: "Location services are not allowed for this app")
                default:
                    provideDirections()
            }
            
        }else{
            println("Location services are not enabled")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

