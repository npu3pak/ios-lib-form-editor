import UIKit

@IBDesignable public class FETextField: UITextField {
    @IBInspectable public var onValueChanged: (() -> Void)? {
        didSet {
            setUp()
        }
    }
    @IBInspectable public var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            setUp()
        }
    }
    @IBInspectable public var inputMask: String? = nil {
        didSet {
            setUp()
        }
    }
    @IBInspectable public var inputMaskForwardDecoration: Bool = true {
        didSet {
            setUp()
        }
    }
    
    public var maxLength: Int? = nil {
        didSet {
            setUp()
        }
    }
    
    override public var text: String? {
        didSet {
            setUp()
        }
    }
    
    private var delegateWrapper: UITextFieldDelegateWrapper?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    func setUp() {
        autocorrectionType = .no;
        
        delegateWrapper = UITextFieldDelegateWrapper()
        delegateWrapper?.mask = inputMask
        delegateWrapper?.inputMaskForwardDecoration = inputMaskForwardDecoration
        delegateWrapper?.textFieldDelegate = textFieldDelegate
        delegateWrapper?.maxLength = maxLength
        delegateWrapper?.onValueChanged = onValueChanged
        
        delegate = delegateWrapper
        
        if text != nil && inputMask != nil {
            super.text = text!.applyingMask(inputMask!, forwardDecoration: inputMaskForwardDecoration)
        }
    }
    
    public var textWithoutMask: String? {
        return delegateWrapper?.getRawValue(fromMaskedValue: self.text) ?? self.text
    }
}

fileprivate class UITextFieldDelegateWrapper: NSObject, UITextFieldDelegate {
    var mask: String?
    var inputMaskForwardDecoration: Bool = true
    var textFieldDelegate: UITextFieldDelegate?
    var maxLength: Int? = nil
    
    var onValueChanged: (() -> Void)?
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDelegate?.textFieldDidEndEditing?(textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldDelegateResult = textFieldDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        let hasMask = mask?.length ?? 0 > 0
        
        if hasMask {
            return textFieldWithMask(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else {
            let isChanged = textFieldWithoutMask(textField, shouldChangeCharactersIn: range, replacementString: string)
            if isChanged {
                onValueChanged?()
            }
            return textFieldDelegateResult && isChanged
        }
    }
    
    func textFieldWithMask(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Если маски нет - никакого форматирования не выполняем
        guard let mask = mask, mask.length > 0 else {
            return false
        }
        
        let oldValue = textField.text ?? ""
        
        //Если в поле ввода ничего нет - форматиируем и вставляем новое знаение
        if oldValue.length == 0 {
            textField.text = string.applyingMask(mask, forwardDecoration: inputMaskForwardDecoration)
            onValueChanged?()
            return false
        }
        
        //Проверяем, есть ли в изменяемом диапазоне значащие символы
        var rangeContainsNonMaskChars = false
        for i in range.location ..< (range.location + range.length) {
            if !mask.isMaskDecorCharacter(at: i) {
                rangeContainsNonMaskChars = true
                break
            }
        }
        
        //Если в изменяемом диапазоне нет значащих символов - расширяем его влево(для удаления) или вправо(для вставки)
        var replacementRange = range
        if !rangeContainsNonMaskChars {
            while mask.isMaskDecorCharacter(at: replacementRange.location) {
                if string == "" {
                    replacementRange.location -= 1
                } else {
                    replacementRange.location += 1
                }
                //Уперлись в маску в начале
                if replacementRange.location < 0 || replacementRange.location == 0 && mask.isMaskDecorCharacter(at: replacementRange.location) {
                    onValueChanged?()
                    return false
                }
            }
        }
        
        //Проецируем изменяемый диапазон на значение без маски. Определяем, какая часть значения без маски изменяется
        var rawValue = ""
        var rawValueRangeLocation = 0
        var rawValueRangeLength = 0
        
        for i in 0..<oldValue.length {
            if !mask.isMaskDecorCharacter(at: i) {
                rawValue.append(oldValue.substring(i, length: 1))
                if i < replacementRange.location {
                    rawValueRangeLocation += 1
                }
                
                if i >= replacementRange.location && i < replacementRange.location + replacementRange.length {
                    rawValueRangeLength += 1
                }
            }
        }
        
        //Изменяем значение без маски
        rawValue.replace(nsRange: NSRange(location: rawValueRangeLocation, length: rawValueRangeLength), replacementString: string)
        
        //Проверяем, не вышло ли значение без маски за максимальную длину
        var maxRawLength = 0
        for i in 0..<mask.length {
            if !mask.isMaskDecorCharacter(at: i) {
                maxRawLength += 1
            }
        }
        
        if rawValue.length > maxRawLength {
            onValueChanged?()
            return false
        }
        
        //Накладываем маску и показываем получившееся значение в поле ввода
        let masked = rawValue.applyingMask(mask, forwardDecoration: inputMaskForwardDecoration)
        textField.text = masked
        
        //Расчитываем и задаем новое положение указателя
        //Сначала вычисляем, где бы находился курсор, если бы не было маски
        //При удалении (string == "") курсор остается в начале изменяемого диапазона. При вставке - смещается вправо на длину вставляемого текста
        let rawValueLengthBeforeCursor = string == "" ? rawValueRangeLocation : rawValueRangeLocation + string.length
        //Отрезаем значение без маски до расчитанного положения курсора
        let rawValueBeforeCursor = rawValue.substring(0, length: rawValueLengthBeforeCursor)
        //Накладываем на получившееся значение маску и вычисляем длину получившегося выражения
        let maskedRawValueBeforeCursor = rawValueBeforeCursor.applyingMask(mask, forwardDecoration: inputMaskForwardDecoration)
        let newCursorPosition = maskedRawValueBeforeCursor.length
        //Перемещаем курсор
        textField.setCursorPosition(newCursorPosition)
        
        onValueChanged?()
        return false
    }
    
    func textFieldWithoutMask(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else {
            return true
        }
        
        guard let maxLength = maxLength else {
            return true
        }
        
        text.replace(nsRange: range, replacementString: string)
        return text.length <= maxLength
    }
    
    func getRawValue(fromMaskedValue maskedValue: String?) -> String? {
        return maskedValue?.removingMask(mask)
    }
}

fileprivate extension UITextField {
    func setCursorPosition(_ position: Int) {
        let position = self.position(from: beginningOfDocument, offset: position)!
        selectedTextRange = textRange(from: position, to: position)
    }
}


