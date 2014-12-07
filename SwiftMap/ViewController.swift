//
//  ViewController.swift
//  SwiftMap
//
//  Created by Vink on 06.12.2014.
//  Copyright (c) 2014 winklerstudio. All rights reserved.
//
import Foundation
import CoreLocation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var jsonTextView: UITextView!
    @IBOutlet weak var mapShowButton: UIButton!
    @IBOutlet weak var jsonButton: UIButton!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    var jsonImage: String!
    var jsonLongitude: CLLocationDegrees!
    var jsonLatitude: CLLocationDegrees!
    var jsonText: String!
    var image: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapShowButton.enabled = false
        mapShowButton.hidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segueMap") {
            var mapViewController: MapViewController = segue.destinationViewController as MapViewController;
            mapViewController.image = self.image as UIImage
            mapViewController.latitude = self.jsonLatitude as CLLocationDegrees
            mapViewController.longitude = self.jsonLongitude as CLLocationDegrees
            mapViewController.text = self.jsonText as String
            
        }
    }
    
    // json parser
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var error: NSError?
        var jsonDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        return jsonDictionary
    }
    
    
    func loadJson() {
        
        // init action
        actIndicator.startAnimating()
        mapShowButton.enabled = false
        mapShowButton.hidden = true
        jsonButton.enabled = false
        jsonButton.hidden = false
        
        jsonTextView.text = "loading data..."
        
        // json data, replace it with your own location
        let jsonURLString = "http://winklerstudio.com/test.json"
        let jsonURL: NSURL? = NSURL(string: jsonURLString)!
        var dataJSON: NSData?
        
        // parse data
        if jsonURL == nil {
            self.displayAlertWithTitle("Data download problem",
                message: "Can't read data")
            // buttons
            self.mapShowButton.enabled = false
            self.mapShowButton.hidden = true
            self.jsonButton.enabled = true
            
            self.actIndicator.stopAnimating()
            
            return
            
        }
        
        //
        dataJSON = NSData(contentsOfURL: jsonURL!)
        
        if dataJSON == nil {
            self.displayAlertWithTitle("Data download problem",
                message: "Can't read data")
            
            // buttons
            self.mapShowButton.enabled = false
            self.mapShowButton.hidden = true
            self.jsonButton.enabled = true
            
            self.actIndicator.stopAnimating()
            
            return
        }
        
        //
        var parsedJSON = self.parseJSON(dataJSON!)
        
        jsonImage = parsedJSON["image"] as String
        jsonLongitude = parsedJSON["location"]!["longitude"] as CLLocationDegrees
        jsonLatitude = parsedJSON["location"]!["latitude"] as CLLocationDegrees
        jsonText = parsedJSON["text"] as String
        
        // get image from json url
        let imageURL: NSURL = NSURL(string: jsonImage)!
        
        var request: NSURLRequest = NSURLRequest(URL: imageURL)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                self.image = UIImage(data: data)
                
                // json data preview
                var outputText: String = "jsonImage: \(self.jsonImage)\n\n"
                outputText += "jsonLong: \(self.jsonLongitude)\n\n"
                outputText += "jsonLat: \(self.jsonLatitude)\n\n"
                outputText += "jsonText: \(self.jsonText)"
                
                self.jsonTextView.text = outputText
                
                // buttons
                self.mapShowButton.enabled = true
                self.mapShowButton.hidden = false
                self.jsonButton.enabled = true
                
                self.actIndicator.stopAnimating()
                
            }
            else {
                println("Error")
            }
            
        })
        
        
    }
    
    // actions
    @IBAction func loadJsonAction (){
        println("loadJsonAction")
        
        if Reachability.isConnectedToNetwork() {
            println("connection ok")
            self.loadJson()
        } else {
            self.displayAlertWithTitle("Network connection problem",
                message: "Can't connect to network")
        }
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
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
    
}

// extend
extension Double {
    func toString() -> String {
        return String(format: "%.10f",self)
    }
}
