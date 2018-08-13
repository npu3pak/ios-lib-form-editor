import UIKit

public class FESwitchCell: UITableViewCell, FormParamFacadeDelegate {
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var valueSwitch: UISwitch!
    
    private var param: FESwitch?
    private var facade: FormParamFacade?
    
    func configure(facade: FormParamFacade) {
        self.facade = facade
        self.param = facade.param as? FESwitch
        
        facade.delegate = self
        
        update()
    }
    
    func update() {
        guard let param = self.param else {
            return
        }
        
        titleLabel.text = param.title
        titleLabel.textColor = param.readOnly ? UIColor.lightGray : UIColor.black
        
        valueSwitch.isOn = param.value
        valueSwitch.accessibilityIdentifier = param.accessibilityIdentifier
        valueSwitch.isEnabled = !param.readOnly
    }

    @IBAction public func switchValueDidChange(_ sender: UISwitch) {
        let newValue = valueSwitch.isOn
        param?.onValueChanged(newValue)
    }
    
    func beginEditing() {
        
    }
    
    func endEditing(){
        
    }
}
