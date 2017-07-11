//
//  PFEParam.swift
//  FormEditor
//
//  Created by Evgeniy Safronov on 08.07.17.
//  Copyright © 2017 Evgeniy Safronov. All rights reserved.
//

import UIKit

public protocol PFEParam: class {
    var id: String {get}
    
    var cellNibName: String {get}
    
    var cellReuseId: String {get}
    
    var canReceiveFocus: Bool {get}
    
    func configure(cell: UITableViewCell, facade: FormParamFacade)
    
    func select()
    
    func isVisible() -> Bool
    
    func equals(other: PFEParam) -> Bool
}
