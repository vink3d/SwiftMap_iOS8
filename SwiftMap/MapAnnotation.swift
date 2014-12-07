//
//  MapAnnotation.swift
//  SwiftMap
//
//  Created by Vink on 07.12.2014.
//  Copyright (c) 2014 winklerstudio. All rights reserved.
//

import Foundation
import UIKit
import MapKit

func == (left: PinColor, right: PinColor) -> Bool{
    return left.rawValue == right.rawValue
}

/* The various pin colors that our annotation can have */
enum PinColor : String{
    case Red = "Red"
    case Green = "Green"
    case Purple = "Purple"
    
    func toPinColor() -> MKPinAnnotationColor{
        switch self{
        case .Red:
            return .Red
        case .Green:
            return .Green
        case .Purple:
            return .Purple
        default:
            return .Red
        }
    }
}

class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var title: String!
    var subtitle: String!
    var image: UIImage!
    var pinColor: PinColor!

    init(coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String,
        image: UIImage,
        pinColor: PinColor){
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.pinColor = pinColor
            
            super.init()
    }
    
    convenience init(coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String,
        image: UIImage){
            self.init(coordinate: coordinate,
                title: title,
                subtitle: subtitle,
                image: image,
                pinColor: .Red)
    }
    
}

