import UIKit

class FESelector: PFEParam {
    var id: String
    var cellNibName = "FESelector"
    var cellReuseId = "FESelector"
    var canReceiveFocus = true
    
    var accessibilityIdentifier: String?
    var title: String?
    var value: String?
    var readOnly: Bool
    var items: [(value:String?, visibleValue:String?)]?
    var visible: Bool = true
    
    var valueChangeListener: ((String?) -> Void)?
    
    init(id: String, title: String? = nil, value: String? = nil, readOnly: Bool = false, visible: Bool = true, accessibilityIdentifier: String? = nil, listener: ((String?) -> Void)? = nil, items: () -> [(value:String?, visibleValue:String?)]?) {
        self.id = id
        self.title = title
        self.value = value
        self.readOnly = readOnly
        self.items = items()
        self.visible = visible
        self.accessibilityIdentifier = accessibilityIdentifier
        self.valueChangeListener = listener
    }
    
    func configure(cell: UITableViewCell, facade: FormParamFacade) {
        if let paramCell = cell as? FESelectorCell {
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
        guard let other = other as? FESelector else {
            return false
        }
        
        return other.id == id &&
            other.value == value &&
            other.title == title &&
            other.readOnly == readOnly &&
            other.items?.count == items?.count &&
            FESelector.equals(items1: items, items2: other.items)
    }
    
    private static func equals(items1: [(value:String?, visibleValue:String?)]?, items2: [(value:String?, visibleValue:String?)]?) -> Bool {
        
        if items1 == nil && items2 == nil {
            return true
        }
        
        guard let items1 = items1, let items2 = items2 else {
            return false
        }
        
        guard items1.count == items2.count else {
            return false
        }
        
        for i in 0..<items1.count {
            if items1[i].value != items2[i].value || items1[i].visibleValue != items2[i].visibleValue {
                return false
            }
        }
        
        return true
    }
}
