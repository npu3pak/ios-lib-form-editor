import UIKit

public class FETextArea: PFEParam {
    public var id: String
    public var cellReuseId = "FETextArea"
    public var cellNibName = "FETextArea"
    public var allowReuseCell = false
    
    public var accessibilityIdentifier: String?
    public var title: String?
    public var value: String?
    public var readOnly: Bool = false
    public var visible: Bool = true
    
    public var valueChangeListener: ((String?) -> Void)?
    
    public init(id: String, title: String? = nil, value: String? = nil, readOnly: Bool = false, visible: Bool = true, accessibilityIdentifier: String? = nil, listener: ((String?) -> Void)? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.readOnly = readOnly
        self.visible = visible
        self.accessibilityIdentifier = accessibilityIdentifier
        self.valueChangeListener = listener
    }
    
    public func copy(from: PFEParam) {
        guard let from =  from  as? FETextArea else {
            return
        }
        
        self.id = from.id
        self.title = from.title
        self.value = from.value
        self.readOnly = from.readOnly
        self.visible = from.visible
        self.accessibilityIdentifier = from.accessibilityIdentifier
        self.valueChangeListener = from.valueChangeListener
    }
    
    public var canReceiveFocus: Bool {
        return !readOnly && isVisible()
    }
    
    public func configure(cell: UITableViewCell, facade: FormParamFacade) {
        if let paramCell = cell as? FETextAreaCell {
            paramCell.configure(facade: facade)
        }
    }
    
    public func select() {
        
    }
    
    public func onValueChanged(_ newValue: String?) {
        value = newValue
        valueChangeListener?(newValue)
    }
    
    public func isVisible() -> Bool {
        return visible
    }
    
    public func equals(other: PFEParam) -> Bool {
        guard let other = other as? FETextArea else {
            return false
        }
        
        return other.id == id &&
            other.value == value &&
            other.title == title &&
            other.readOnly == readOnly
    }
}

