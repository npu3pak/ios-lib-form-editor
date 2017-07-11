import UIKit

class FEDate: PFEParam {
    var id: String
    var cellNibName = "FEDate"
    var cellReuseId = "FEDate"
    var canReceiveFocus = true
    
    var title: String?
    var value: Date?
    var readOnly: Bool
    var minDate: Date
    var maxDate: Date
    var visible: Bool
    var accessibilityIdentifier: String?
    
    var valueChangeListener: ((Date) -> Void)?
    
    init(id: String, paramName: String? = nil, title: String? = nil, value: Date? = nil, minDate: Date, maxDate: Date, readOnly: Bool = false, visible: Bool = true, accessibilityIdentifier: String? = nil, listener: ((Date) -> Void)? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.readOnly = readOnly
        self.visible = visible
        self.accessibilityIdentifier = accessibilityIdentifier
        self.minDate = minDate
        self.maxDate = maxDate
        self.valueChangeListener = listener
    }
    
    func configure(cell: UITableViewCell, facade: FormParamFacade) {
        if let paramCell = cell as? FEDateCell {
            paramCell.configure(facade: facade)
        }
    }
    
    func select() {
        
    }
    
    func onValueChanged(_ newValue: Date) {
        value = newValue
        valueChangeListener?(newValue)
    }
    
    func isVisible() -> Bool {
        return visible
    }
    
    func equals(other: PFEParam) -> Bool {
        guard let other = other as? FEDate else {
            return false
        }
        
        return other.id == id &&
            other.value == value &&
            other.title == title &&
            other.minDate == minDate &&
            other.maxDate == maxDate &&
            other.readOnly == readOnly
    }
}
