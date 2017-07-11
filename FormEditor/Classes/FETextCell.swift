import UIKit

class FETextCell: UITableViewCell, UITextFieldDelegate, FormParamFacadeDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueTextField: FETextField!
    
    private var param: FEText?
    private var facade: FormParamFacade?
    
    func configure(facade: FormParamFacade) {
        self.facade = facade
        self.param = facade.param as? FEText
        
        facade.delegate = self
        
        update()
    }
    
    func update() {
        guard let param = self.param else {
            return
        }
        
        guard let facade = self.facade else {
            return
        }
        
        titleLabel.text = param.title
        
        valueTextField.textFieldDelegate = self
        valueTextField.returnKeyType = .done
        valueTextField.placeholder = param.placeholder
        valueTextField.isEnabled = !param.readOnly
        valueTextField.keyboardType = param.keyboardType
        valueTextField.autocapitalizationType = param.autocapitalizationType
        valueTextField.maxLength = param.maxLength
        valueTextField.text = param.value
        valueTextField.inputMask = param.inputMask
        valueTextField.inputMaskForwardDecoration = param.inputMaskForwardDecoration
        valueTextField.accessibilityIdentifier = param.accessibilityIdentifier
        valueTextField.enableParamsNavigationToolbar(moveNextClosure: facade.editNextParam, movePreviousClosure: facade.editPreviousParam)
        
    }
    
    func beginEditing() {
        if !valueTextField.isFirstResponder {
            DispatchQueue.main.async {
                self.valueTextField.becomeFirstResponder()
            }
        }
    }
    
    func endEditing() {        
        if valueTextField.isFirstResponder {
            DispatchQueue.main.async {
                self.valueTextField.resignFirstResponder()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        valueTextField.textColor = UIColor.turquoise
        facade?.didBeginEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldValue = textField.text as NSString?
        let newValue = oldValue?.replacingCharacters(in: range, with: string)
        param?.onValueChanged(newValue)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        valueTextField.textColor = UIColor.black
        facade?.didEndEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
