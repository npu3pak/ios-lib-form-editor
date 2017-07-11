import UIKit

class FEText: PFEParam {
    var id: String
    var cellReuseId = "FEText"
    var cellNibName = "FEText"
    
    var accessibilityIdentifier: String?
    var title: String?
    var value: String?
    var placeholder: String?
    var keyboardType: UIKeyboardType
    var autocapitalizationType: UITextAutocapitalizationType
    var inputMask: String?
    var readOnly: Bool = false
    var inputMaskForwardDecoration: Bool
    var visible: Bool = true
    var maxLength: Int?
    
    var valueChangeListener: ((String?) -> Void)?
    
    init(id: String, title: String? = nil, value: String? = nil, placeholder: String? = nil, keyboardType: UIKeyboardType = .default, autocapitalizationType: UITextAutocapitalizationType = .none, inputMask: String? = nil, inputMaskForwardDecoration: Bool = true, maxLength: Int? = nil, readOnly: Bool = false, visible: Bool = true, accessibilityIdentifier: String? = nil, listener: ((String?) -> Void)? = nil) {
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
    
    var canReceiveFocus: Bool {
        return !readOnly
    }
    
    func configure(cell: UITableViewCell, facade: FormParamFacade) {
        if let paramCell = cell as? FETextCell {
            paramCell.configure(facade: facade)
        }
    }
    
    func select() {
        
    }
    
    func onValueChanged(_ newValue: String?) {
        value = newValue
        valueChangeListener?(newValue)
    }
    
    func isVisible() -> Bool {
        return visible
    }
    
    func equals(other: PFEParam) -> Bool {
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
