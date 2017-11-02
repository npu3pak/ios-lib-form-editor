import UIKit

class FETextCell: UITableViewCell, UITextFieldDelegate, FormParamFacadeDelegate {
    
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
        
        accessoryView = self.accessory
        
        valueTextField.onValueChanged = onTextFieldValueChanged
        valueTextField.textFieldDelegate = self
        valueTextField.returnKeyType = .done
        valueTextField.placeholder = param.title
        valueTextField.isEnabled = !param.readOnly
        
        valueTextField.textColor = facade.isEditing ? facade.preferences.colors.text.editing : facade.preferences.colors.text.normal
        
        valueTextField.keyboardType = param.keyboardType
        valueTextField.autocapitalizationType = param.autocapitalizationType
        valueTextField.maxLength = param.maxLength
        valueTextField.text = param.value
        valueTextField.inputMask = param.inputMask
        valueTextField.inputMaskForwardDecoration = param.inputMaskForwardDecoration
        valueTextField.accessibilityIdentifier = param.accessibilityIdentifier
        
        if facade.isEditing {
            beginEditing()
        }
    }
    
    var accessory: UIView? {
        guard let accessoryImageNames = param?.accessoryImageNames, accessoryImageNames.count > 0 else {
            return nil
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        //Учитываем отступы
        let margin: CGFloat = 0
        
        //Рассчитываем размеры контейнера
        var containerWidth: CGFloat = 0
        var containerHeight: CGFloat = 0
        
        var x: CGFloat = 0 //Позиция, в которую помещаем картинку
        
        for accessoryImageName in accessoryImageNames {
            let image = UIImage(named: accessoryImageName)!
            
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let imageView = UIImageView(image: image)
            containerView.addSubview(imageView)
            imageView.frame = CGRect(x: x, y: 0, width:imageWidth, height: imageHeight)
            
            x += imageWidth + margin
            
            containerWidth += imageWidth //общая ширина элементов
            containerHeight = max(containerHeight, imageHeight) //высота самого большого элемента
        }
        
        containerWidth += margin * CGFloat(accessoryImageNames.count - 1)
        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        
        return containerView
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
        let result = enableNavigationToolbar()
        return result
    }
    
    internal func enableNavigationToolbar() -> Bool {
        guard let facade = self.facade else {
            return false
        }
        
        valueTextField.enableParamsNavigationToolbar(preferences: facade.preferences, moveNextClosure: facade.functionForMoveToNextParam, movePreviousClosure: facade.functionForMoveToPreviousParam)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let editingTextColor = facade?.preferences.colors.text.editing {
            valueTextField.textColor = editingTextColor
        }
        
        facade?.didBeginEditing()
    }
    
    func onTextFieldValueChanged(newValue: String?) {
        let newValue = valueTextField.textWithoutMask
        param?.onValueChanged(newValue)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let normalTextColor = facade?.preferences.colors.text.normal {
            valueTextField.textColor = normalTextColor
        }
        facade?.didEndEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
