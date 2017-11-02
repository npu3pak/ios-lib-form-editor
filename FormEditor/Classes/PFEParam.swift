import UIKit

public protocol PFEParam: class {
    var id: String {get}
    
    var cellNibName: String {get}
    
    var cellReuseId: String {get}
    
    var allowReuseCell: Bool {get}
    
    var canReceiveFocus: Bool {get}
    
    func configure(cell: UITableViewCell, facade: FormParamFacade)
    
    func select()
    
    func isVisible() -> Bool
    
    func equals(other: PFEParam) -> Bool
    
    func copy(from: PFEParam)
}
