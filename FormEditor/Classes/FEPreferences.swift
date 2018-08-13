//
//  FEPreferences.swift
//  FormEditor
//
//  Created by Evgeniy Safronov on 12.10.17.
//

import Foundation

public class FEPreferences {
    
    public var colors = Colors()
    
    public class Colors {
        public var text = Text()
        
        public class Text {
            public var editing = UIColor.red
            public var normal = UIColor.darkText
            public var placeholder = UIColor.lightGray
        }
        
        public var inputAccessory = InputAccessory()
        
        public class InputAccessory {
            public var background = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
            public var navigation = UIColor.white
            public var done = UIColor.red
        }
    }
    
    public var labels = Labels()
    
    public class Labels {
        public var inputAccessory = InputAccessory()
        
        public class InputAccessory {
            public var back = "Previous"
            public var forward = "Next"
            public var done = "Done"
        }
    }

    public var customNibsBundle = Bundle(for: FEViewController.self)

    public var customCellNibs: [(PFEParam.Type, String)] = []
}
