import UIKit

class FEDateCell: UITableViewCell, UITextFieldDelegate, FormParamFacadeDelegate {
    
    @IBOutlet var dateTextField: UITextField!
    
    private var param: FEDate?
    private var facade: FormParamFacade?
    
    func configure(facade: FormParamFacade) {
        self.facade = facade
        self.param = facade.param as? FEDate
        
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
        
        dateTextField.textColor = !param.readOnly
            ? (facade.isEditing ? facade.preferences.colors.text.editing : facade.preferences.colors.text.normal)
            : facade.preferences.colors.text.placeholder
        
        dateTextField.isEnabled = !param.readOnly
        dateTextField.accessibilityIdentifier = param.accessibilityIdentifier
        dateTextField.text = textFieldValue(date: param.value)
        dateTextField.placeholder = param.title
        dateTextField.delegate = self
        
        if facade.isEditing {
            beginEditing()
        }
    }
    
    private func textFieldValue(date: Date?) -> String? {
        guard let param = self.param else {
            return nil
        }
        
        guard let date = date else {
            return nil
        }
        
        let visibleValue = date.asString(.literalDmy)
        
        return String(format: param.displayableValueFormat, visibleValue)
    }
    
    private func datePicker() -> UIDatePicker? {
        guard let param = self.param else {
            return nil
        }
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        if let date = param.value {
            datePicker.date = date
        }
        
        datePicker.minimumDate = param.minDate
        datePicker.maximumDate = param.maxDate
        datePicker.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        return datePicker
    }
    
    func beginEditing() {
        if !dateTextField.isFirstResponder {
            DispatchQueue.main.async {
                self.dateTextField.becomeFirstResponder()
            }
        }
    }
    
    func endEditing() {
        if dateTextField.isFirstResponder {
            DispatchQueue.main.async {
                self.dateTextField.resignFirstResponder()
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let facade = self.facade else {
            return false
        }
        
        dateTextField.enableParamsNavigationToolbar(preferences: facade.preferences, moveNextClosure: facade.editNextParam, movePreviousClosure: facade.editPreviousParam)
        dateTextField.inputView = datePicker()
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
    
    func valueChanged(_ picker: UIDatePicker) {
        dateTextField.text = textFieldValue(date: picker.date)
        param?.onValueChanged(picker.date)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
