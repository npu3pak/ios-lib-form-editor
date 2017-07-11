//
//  Colors.swift
//  SwiftModules
//
//  Created by Alexander Smetannikov on 26/05/2017.
//  Copyright © 2017 Altarix. All rights reserved.
//

import UIKit

extension UIColor {
    //Малиновый
    static var crimson: UIColor {
        return UIColor(red: 213/255, green: 14/255, blue: 114/255, alpha: 1)
    }
    
    //Бирюзовый
    static var turquoise: UIColor {
        return UIColor(red: 0/255, green: 176/255, blue: 161/255, alpha: 1)
    }
    
    static var lightSeaGreen: UIColor {
        return UIColor(red: 14/255, green: 176/255, blue: 160/255, alpha: 1)
    }
    
    static var lightAquamarine: UIColor {
        return UIColor (red: 231/255, green: 245/255, blue: 227/255, alpha: 1)
    }
    
    static var aquamarine: UIColor {
        return UIColor(red: 0.7843, green: 0.9294, blue: 0.8667, alpha: 1)
        
    }
    
    static var lightLightGray: UIColor {
        return UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
    }
}

struct Colors {
    struct SegmentedControl {
        static let defaultBackground = UIColor(red: 0.7843, green: 0.9294, blue: 0.8667, alpha: 1)
        static let selectedBackground = UIColor(red: 14/255, green: 176/255, blue: 160/255, alpha: 1)
        static let defaultText = UIColor(red: 14/255, green: 176/255, blue: 160/255, alpha: 1)
        static let selectedText = UIColor.white
    }
    
    static let activityIndicator = UIColor.lightSeaGreen
    
    struct InputAccessoryView {
        static let background = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        static let navigaionButton = UIColor.white
        static let doneButton = UIColor.turquoise
    }
}
