import UIKit

public class FETextAreaCell: UITableViewCell, UITextViewDelegate, FormParamFacadeDelegate {
    
    @IBOutlet public var valueTextView: FETextView!
    
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
        valueTextView.textColor = facade.isEditing ? facade.preferences.colors.text.editing : facade.preferences.colors.text.normal
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
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard let facade = self.facade else {
            return false
        }
        valueTextView.enableParamsNavigationToolbar(preferences: facade.preferences, moveNextClosure: facade.editNextParam, movePreviousClosure: facade.editPreviousParam)
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if let editingTextColor = facade?.preferences.colors.text.editing {
            valueTextView.textColor = editingTextColor
        }
        facade?.didBeginEditing()
    }
    
    func onTextViewTextChanged() {
        param?.onValueChanged(valueTextView.text)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if let normalTextColor = facade?.preferences.colors.text.normal {
            valueTextView.textColor = normalTextColor
        }
        facade?.didEndEditing()
    }
}
