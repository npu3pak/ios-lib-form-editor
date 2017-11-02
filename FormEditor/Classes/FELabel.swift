import UIKit

public class FELabel: PFEParam {
    public var id: String
    public var cellReuseId = "FELabel"
    public var cellNibName = "FELabel"
    public var allowReuseCell = false
    
    public var accessibilityIdentifier: String?
    public var title: String?
    public var value: String?
    public var mask: String?
    public var alwaysShowTitle: Bool
    public var visible: Bool = true
    
    public var onSelect: (()->Void)?
    
    public init(id: String, title: String? = nil, value: String? = nil, mask: String? = nil, alwaysShowTitle: Bool = false, visible: Bool = true, accessibilityIdentifier: String? = nil, onSelect: (()->Void)? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.mask = mask
        self.alwaysShowTitle = alwaysShowTitle
        self.visible = visible
        self.accessibilityIdentifier = accessibilityIdentifier
        self.onSelect = onSelect
    }
    
    public func copy(from: PFEParam) {
        guard let from = from as? FELabel else {
            return
        }
        
        self.id = from.id
        self.title = from.title
        self.value = from.value
        self.mask = from.mask
        self.alwaysShowTitle = from.alwaysShowTitle
        self.visible = from.visible
        self.accessibilityIdentifier = from.accessibilityIdentifier
        self.onSelect = from.onSelect
    }
    
    public var canReceiveFocus: Bool {
        return false
    }
    
    public func configure(cell: UITableViewCell, facade: FormParamFacade) {
        if let paramCell = cell as? FELabelCell {
            paramCell.configure(facade: facade)
        }
    }
    
    public func select() {
        onSelect?()
    }
    
    public func isVisible() -> Bool {
        return visible
    }
    
    public func equals(other: PFEParam) -> Bool {
        guard let other = other as? FEText else {
            return false
        }
        
        return other.id == id &&
            other.value == value &&
            other.title == title
    }
}
