import Foundation

public class FESwitch: PFEParam {
    public var id: String
    public var cellNibName = "FESwitch"
    public var cellReuseId = "FESwitch"
    public var allowReuseCell = false
    
    public var title: String? = nil
    public var value: Bool = false
    public var readOnly: Bool = false
    public var visible: Bool = true
    public var accessibilityIdentifier: String? = nil
    
    public var listener: ((Bool) -> Void)? = nil
    
    public var canReceiveFocus = false
    
    public init(id: String, title: String? = nil, value: Bool = false, readOnly: Bool = false, visible: Bool = true, accessibilityIdentifier: String? = nil, listener: ((Bool) -> Void)? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.readOnly = readOnly
        self.visible = visible
        self.accessibilityIdentifier = accessibilityIdentifier
        self.listener = listener
    }
    
    public func copy(from: PFEParam) {
        guard let from = from as? FESwitch else {
            return
        }
        
        self.id = from.id
        self.title = from.title
        self.value = from.value
        self.readOnly = from.readOnly
        self.visible = from.visible
        self.accessibilityIdentifier = from.accessibilityIdentifier
        self.listener = from.listener
    }
    
    public func configure(cell: UITableViewCell, facade: FormParamFacade) {
        if let paramCell = cell as? FESwitchCell {
            paramCell.configure(facade: facade)
        }
    }
    
    public func select() {
        
    }
    
    public func isVisible() -> Bool {
        return visible
    }
    
    public func onValueChanged(_ newValue: Bool) {
        value = newValue
        listener?(newValue)
    }
    
    public func equals(other: PFEParam) -> Bool {
        guard let other = other as? FESwitch else {
            return false
        }
        
        return other.id == id &&
            other.value == value &&
            other.title == title &&
            other.readOnly == readOnly &&
            other.visible == visible
    }
}
