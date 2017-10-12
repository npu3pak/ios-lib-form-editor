import UIKit

class FETextAreaCell: UITableViewCell, UITextViewDelegate, FormParamFacadeDelegate {
    
    @IBOutlet var valueTextView: FETextView!
    
    private var param: FETextArea?
    private var facade: FormParamFacade?
    
    func configure(facade: FormParamFacade) {
        self.facade = facade
        self.param = facade.param as? FETextArea
        
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
        
        valueTextView.placeholderText = param.title ?? ""
        valueTextView.text = param.value
        valueTextView.delegate = self
        valueTextView.isEditable = !param.readOnly
        valueTextView.textColor = facade.isEditing ? UIColor.turquoise : UIColor.black
        valueTextView.accessibilityIdentifier = param.accessibilityIdentifier
        valueTextView.onTextChanged = onTextViewTextChanged
        
        if facade.isEditing {
            beginEditing()
        }
    }
    
    func beginEditing() {
        if !valueTextView.isFirstResponder {
            DispatchQueue.main.async {
                self.valueTextView.becomeFirstResponder()
            }
        }
    }
    
    func endEditing() {
        if valueTextView.isFirstResponder {
            DispatchQueue.main.async {
                self.valueTextView.resignFirstResponder()
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard let facade = self.facade else {
            return false
        }
        valueTextView.enableParamsNavigationToolbar(moveNextClosure: facade.editNextParam, movePreviousClosure: facade.editPreviousParam)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        valueTextView.textColor = UIColor.turquoise
        facade?.didBeginEditing()
    }
    
    func onTextViewTextChanged() {
        param?.onValueChanged(valueTextView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        valueTextView.textColor = UIColor.black
        facade?.didEndEditing()
    }
}
