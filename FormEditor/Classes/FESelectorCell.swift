import UIKit

class FESelectorCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, FormParamFacadeDelegate {
    
    @IBOutlet var valueTextField: UITextField!
    
    private var param: FESelector?
    private var facade: FormParamFacade?
    
    func configure(facade: FormParamFacade) {
        self.facade = facade
        self.param = facade.param as? FESelector
        
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
        
        valueTextField.textColor = !param.readOnly
            ? (facade.isEditing ? facade.preferences.colors.text.editing : facade.preferences.colors.text.normal)
            : facade.preferences.colors.text.placeholder
        valueTextField.text = textFieldValue(value: param.value)
        valueTextField.isEnabled = !param.readOnly
        valueTextField.delegate = self
        valueTextField.placeholder = param.title
        valueTextField.accessibilityIdentifier = param.accessibilityIdentifier
        
        if facade.isEditing {
            beginEditing()
        }
    }
    
    private func textFieldValue(value: String?) -> String? {
        guard let value = value else {
            return nil
        }
        
        guard let param = self.param else {
            return nil
        }
        
        let visibleValue = param.items?
            .first(where: {$0.value == value})?
            .visibleValue ?? ""
        
        return String(format: param.displayableValueFormat, visibleValue)
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let facade = self.facade else {
            return false
        }
        valueTextField.inputView = pickerView()
        valueTextField.enableParamsNavigationToolbar(preferences: facade.preferences, moveNextClosure: facade.functionForMoveToNextParam, movePreviousClosure: facade.functionForMoveToPreviousParam)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let editingTextColor = facade?.preferences.colors.text.editing {
            textField.textColor = editingTextColor
        }
        facade?.didBeginEditing()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let normalTextColor = facade?.preferences.colors.text.normal {
            textField.textColor = normalTextColor
        }
        facade?.didEndEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
    
    // MARK: Карусель
    
    func pickerView() -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let selectedRow = param?.items?.index(where: {$0.value == param?.value}) ?? 0
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        return pickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return param?.items?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return param?.items?[row].visibleValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let value = param?.items?[row].value
        
        valueTextField.text = textFieldValue(value: value)
        
        param?.onValueChanged(value)
    }
}
