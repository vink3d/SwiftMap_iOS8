//
//  MapController.swift
//  SwiftMap
//
//  Created by Vink on 06.12.2014.
//  Copyright (c) 2014 winklerstudio. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var routeButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    //data
    var manager: CLLocationManager?

    var image: UIImage!
    var latitude:CLLocationDegrees = 52.115489
    var longitude:CLLocationDegrees = 16.554826
    var text:String = ""
    var jsonAnnotation: MapAnnotation!
    
    var coordTarget: CLLocationCoordinate2D!
    var coordUser: CLLocationCoordinate2D!
    var locTarget: CLLocation!
    var locUser: CLLocation!
    
    var distance:Int = 0
    
    let delta:CLLocationDegrees = 0.01

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // map
        coordTarget = CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
        locTarget = CLLocation(latitude: latitude, longitude: longitude)
        
        var span = MKCoordinateSpanMake(delta, delta)
        var region = MKCoordinateRegion(center: coordTarget, span: span)
        
        mapView.setRegion(region, animated: true)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addPin()
        initManager()
        
    }
    
    //
    
    func mapView(mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!{
            
            if annotation is MapAnnotation == false{
                return nil
            }
            

            let senderAnnotation = annotation as MapAnnotation
            
            let pinReusableIdentifier = senderAnnotation.pinColor.rawValue
            
            /* Using the identifier we retrieved above, we will
            attempt to reuse a pin in the sender Map View */
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(
                pinReusableIdentifier) as? MKPinAnnotationView
            
            if annotationView == nil{
                /* If we fail to reuse a pin, then we will create one */
                annotationView = MKPinAnnotationView(annotation: senderAnnotation,
                    reuseIdentifier: pinReusableIdentifier)
                
                annotationView!.canShowCallout = true
            }
            
           
            annotationView!.pinColor = senderAnnotation.pinColor.toPinColor()
            
            //additional views
            var imageView = UIImageView(frame: CGRectMake(0, 0, 64, 64))
            imageView.image = senderAnnotation.image
            annotationView!.leftCalloutAccessoryView = imageView
            
            //annotationView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIButton
            return annotationView
            
    }
    
    func initManager(){
        
        // test location services
        if CLLocationManager.locationServicesEnabled(){

            switch CLLocationManager.authorizationStatus(){
                
                case .Denied:
                    displayAlertWithTitle("Not Determined",
                        message: "Location services are not allowed for this app")
                    println("location service denied")
                    
                case .NotDetermined:
                    self.manager = CLLocationManager()

                    self.manager!.delegate = self
                    self.manager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.manager!.requestWhenInUseAuthorization()
                    self.manager!.startUpdatingLocation()
                    println("location service not determined")

                case .Restricted:
                    displayAlertWithTitle("Restricted",
                        message: "Location services are not allowed for this app")
                    println("location service restricted")

                default:
                    self.manager = CLLocationManager()
                    
                    self.manager!.delegate = self
                    self.manager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.manager!.requestWhenInUseAuthorization()
                    self.manager!.startUpdatingLocation()
                    println("location service default")

            }
            
            
        } else {
            println("Location services are not enabled")
        }
    }
    
    func addPin(){

        /* Create the annotations using the location */
        jsonAnnotation = MapAnnotation(coordinate: self.coordTarget,
            title: self.text,
            subtitle: "distance: \(Int(self.distance)) m",
            image: self.image,
            pinColor: .Red)
        
        /* And eventually add them to the map */
        mapView.addAnnotations([jsonAnnotation])
        
        /* And now center the map around the point */
        if(coordTarget != nil){
            setCenterOfMapToLocation(coordTarget)
        }
    }

    func setCenterOfMapToLocation(location: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func getDistance(loc1: CLLocation, loc2: CLLocation) -> Int {
        var output = loc1.distanceFromLocation(loc2)
        
        return Int(output)
    }
    
    func getDirections(){
        
        let request = MKDirectionsRequest()

        let source = MKPlacemark(coordinate: coordUser, addressDictionary: nil)
        request.setSource(MKMapItem(placemark: source))

        /* Get the placemark of the destination address */
        let destination = MKPlacemark(coordinate: coordTarget, addressDictionary: nil)
        request.setDestination(MKMapItem(placemark: destination))
        
        /* Set the transportation method to automobile */
        request.transportType = .Automobile
        
        /* Get the directions */
        let directions = MKDirections(request: request)

        directions.calculateDirectionsWithCompletionHandler{
            (response: MKDirectionsResponse!, error: NSError!) in
            
            /* Display the directions on the Maps app */
            let launchOptions = [
                MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
            
            MKMapItem.openMapsWithItems(
                [response.source, response.destination],
                launchOptions: launchOptions)
        }
    
    }

    
    // location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                
                let pm = placemarks[0] as CLPlacemark
                self.updateLocationInfo(pm)
                
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    
    func updateLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            
            //stop updating location to save battery life
            
            manager!.stopUpdatingLocation()
            
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            // put user location
            var userLatitude = containsPlacemark.location.coordinate.latitude
            var userLongitude = containsPlacemark.location.coordinate.longitude

            coordUser = CLLocationCoordinate2D(latitude: userLatitude,longitude: userLongitude)
            locUser = containsPlacemark.location
            distance = getDistance(locUser, loc2: locTarget)
            jsonAnnotation.subtitle = "distance: \(distance) m"
            distanceLabel.text = "Distance from me: \(distance) m"
            
            // log names
            println(locality)
            println(postalCode)
            println(administrativeArea)
            println(country)
        }
        
    }
    
    //actions
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
    }
    
    @IBAction func centerOnMe(sender: AnyObject) {
        if (coordUser != nil) {
            setCenterOfMapToLocation(coordUser)
        } else {
            displayAlertWithTitle("GPS problem",
                message: "Cant determine your location")
        }
    }
    
    @IBAction func centerOnTarget(sender: AnyObject) {
        if (coordTarget != nil) {
            setCenterOfMapToLocation(coordTarget)
        }
    }
    
    @IBAction func findDirections(sender: AnyObject) {
        if (coordUser != nil) {
            getDirections()
        } else {
            displayAlertWithTitle("GPS problem",
                message: "Cant determine your location")
        }
    }
    
    // alert
    func displayAlertWithTitle(title: String, message: String){
        
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    //
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}