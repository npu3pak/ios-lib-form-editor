import UIKit

public class FEText: PFEParam {
    public var id: String
    public var cellReuseId = "FEText"
    public var cellNibName = "FEText"
    
    public var accessibilityIdentifier: String?
    public var title: String?
    public var value: String?
    public var placeholder: String?
    public var keyboardType: UIKeyboardType
    public var autocapitalizationType: UITextAutocapitalizationType
    public var inputMask: String?
    public var readOnly: Bool = false
    public var inputMaskForwardDecoration: Bool
    public var visible: Bool = true
    public var maxLength: Int?
    
    public var valueChangeListener: ((String?) -> Void)?
    
    public init(id: String, title: String? = nil, value: String? = nil, placeholder: String? = nil, keyboardType: UIKeyboardType = .default, autocapitalizationType: UITextAutocapitalizationType = .none, inputMask: String? = nil, inputMaskForwardDecoration: Bool = true, maxLength: Int? = nil, readOnly: Bool = false, visible: Bool = true, accessibilityIdentifier: String? = nil, listener: ((String?) -> Void)? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.autocapitalizationType = autocapitalizationType
        self.inputMask = inputMask
        self.inputMaskForwardDecoration = inputMaskForwardDecoration
        self.maxLength = maxLength
        self.readOnly = readOnly
        self.visible = visible
        self.accessibilityIdentifier = accessibilityIdentifier
        self.valueChangeListener = listener
    }
    
    public var canReceiveFocus: Bool {
        return !readOnly
    }
    
    public func configure(cell: UITableViewCell, facade: FormParamFacade) {
        if let paramCell = cell as? FETextCell {
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
        guard let other = other as? FEText else {
            return false
        }
        
        return other.id == id &&
            other.value == value &&
            other.title == title &&
            other.placeholder == placeholder &&
            other.inputMask == inputMask &&
            other.keyboardType == keyboardType &&
            other.autocapitalizationType == autocapitalizationType &&
            other.readOnly == readOnly
    }
}
