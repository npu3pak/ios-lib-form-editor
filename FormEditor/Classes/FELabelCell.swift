import UIKit

class FELabelCell: UITableViewCell, FormParamFacadeDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    private var param: FELabel?
    private var facade: FormParamFacade?
    
    func configure(facade: FormParamFacade) {
        self.facade = facade
        self.param = facade.param as? FELabel
        
        facade.delegate = self
        
        update()
    }
    
    func update() {
        guard let param = self.param else {
            return
        }
        
        let hasValue = param.value?.characters.count ?? 0 > 0
        
        if hasValue {
            titleLabel.text = param.alwaysShowTitle ? param.title : nil
            valueLabel.text = param.value?.applyingMask(param.mask, forwardDecoration: true)
            valueLabel.textColor = UIColor.black
        } else {
            titleLabel.text = nil
            valueLabel.text = param.title
            valueLabel.textColor = UIColor.lightGray
        }
        
        valueLabel.accessibilityIdentifier = param.accessibilityIdentifier
        
        if param.onSelect != nil {
            selectionStyle = .default
            accessoryType = .disclosureIndicator
        } else {
            selectionStyle = .none
            accessoryType = .none
        }
    }
    
    func beginEditing() {
    }
    
    func endEditing() {
    }
}
