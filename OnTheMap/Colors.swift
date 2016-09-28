//
//  Colors.swift
//  OnTheMap
//
//  Created by Laura Scully on 28/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import Foundation
import UIKit

func rgbaToUIColor(red:CGFloat, green:CGFloat ,blue:CGFloat, alpha: CGFloat) -> UIColor{
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}

struct Colors {
    var red:UIColor = rgbaToUIColor(255, green: 99, blue: 71, alpha: 1)
    var orange:UIColor = rgbaToUIColor(255, green: 153, blue: 20, alpha: 1)
    var darkOrange:UIColor = rgbaToUIColor(255, green: 94, blue: 10, alpha: 1)
    var blue:UIColor = rgbaToUIColor(16, green: 149, blue: 255, alpha: 1)
    var beige:UIColor = rgbaToUIColor(255, green: 255, blue: 221, alpha: 1)
    var white:UIColor = rgbaToUIColor(255, green: 255, blue: 245, alpha: 1)
    var semitransparent:UIColor = rgbaToUIColor(255, green: 255, blue: 255, alpha: 0.4)
}