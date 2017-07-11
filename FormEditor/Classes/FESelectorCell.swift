import UIKit

class FESelectorCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, FormParamFacadeDelegate {
    
    @IBOutlet var titleLabel: UILabel!
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
        
        titleLabel.text = param.title
        
        let visibleValue = param.items?
            .first(where: {$0.value == param.value})?
            .visibleValue
        
        valueTextField.accessibilityIdentifier = param.accessibilityIdentifier
        valueTextField.text = visibleValue
        valueTextField.delegate = self
        valueTextField.placeholder = nil
        valueTextField.inputView = pickerView()
        valueTextField.enableParamsNavigationToolbar(moveNextClosure: facade.editNextParam, movePreviousClosure: facade.editPreviousParam)
        
        if facade.isEditing {
            beginEditing()
        }
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
        textField.textColor = UIColor.turquoise
        facade?.didBeginEditing()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
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
        let visibleValue = param?.items?[row].visibleValue
        valueTextField.text = visibleValue
        
        let value = param?.items?[row].value
        param?.onValueChanged(value)
    }
}
