import UIKit

class FEDateCell: UITableViewCell, UITextFieldDelegate, FormParamFacadeDelegate {
    
    @IBOutlet var titleLabel: UILabel!
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
        
        titleLabel.text = param.title
        
        dateTextField.isEnabled = !param.readOnly
        dateTextField.accessibilityIdentifier = param.accessibilityIdentifier
        dateTextField.text = param.value?.asString(.dmy)
        dateTextField.placeholder = nil
        dateTextField.delegate = self
        dateTextField.inputView = datePicker()
        dateTextField.enableParamsNavigationToolbar(moveNextClosure: facade.editNextParam, movePreviousClosure: facade.editPreviousParam)
        
        if facade.isEditing {
            beginEditing()
        }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.turquoise
        facade?.didBeginEditing()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
        facade?.didEndEditing()
    }
    
    func valueChanged(_ picker: UIDatePicker) {
        dateTextField.text = picker.date.asString(.dmy)
        param?.onValueChanged(picker.date)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
