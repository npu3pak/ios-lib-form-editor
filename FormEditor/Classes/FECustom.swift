import UIKit

public class FECustom: PFEParam {
    public var id: String
    public var cellReuseId: String
    public var cellNibName: String
    public var allowReuseCell = true
    
    public var visible: Bool
    public var onSelect: (() -> Void)?
    public var configureCell: ((UITableViewCell) -> Void)?
    
    public init(id: String, reuseId: String, nibName: String = "", visible: Bool = true, onSelect: (() -> Void)? = nil, configureCell: ((UITableViewCell) -> Void)? = nil) {
        self.id = id
        self.cellReuseId = reuseId
        self.cellNibName = nibName
        self.visible = visible
        self.onSelect = onSelect
        self.configureCell = configureCell
    }
    
    public func configure(cell: UITableViewCell, facade: FormParamFacade) {
        configureCell?(cell)
    }
    
    public var canReceiveFocus: Bool {
        return false
    }
    
    public func select() {
        onSelect?()
    }
    
    public func isVisible() -> Bool {
        return visible
    }
    
    public func equals(other: PFEParam) -> Bool {
        return false
    }
}
