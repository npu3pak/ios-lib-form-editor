import UIKit

class FECustom: PFEParam {
    var id: String
    var cellReuseId = "FEText"
    var cellNibName = "FEText"
    
    var visible: Bool
    var onSelect: (() -> Void)?
    var configureCell: ((UITableViewCell) -> Void)?
    
    init(id: String, reuseId: String, nibName: String = "", visible: Bool = true, onSelect: (() -> Void)? = nil, configureCell: ((UITableViewCell) -> Void)? = nil) {
        self.id = id
        self.cellReuseId = reuseId
        self.cellNibName = nibName
        self.visible = visible
        self.onSelect = onSelect
        self.configureCell = configureCell
    }
    
    func configure(cell: UITableViewCell, facade: FormParamFacade) {
        configureCell?(cell)
    }
    
    var canReceiveFocus: Bool {
        return false
    }
    
    func select() {
        onSelect?()
    }
    
    func isVisible() -> Bool {
        return visible
    }
    
    func equals(other: PFEParam) -> Bool {
        return false
    }
}
