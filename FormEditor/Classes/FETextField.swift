import UIKit

@IBDesignable class FETextField: UITextField {
    @IBInspectable var onValueChanged: (() -> Void)? {
        didSet {
            setUp()
        }
    }
    @IBInspectable var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            setUp()
        }
    }
    @IBInspectable var inputMask: String? = nil {
        didSet {
            setUp()
        }
    }
    @IBInspectable var inputMaskForwardDecoration: Bool = true {
        didSet {
            setUp()
        }
    }
    @IBInspectable var maxLength: Int? = nil {
        didSet {
            setUp()
        }
    }
    
    override var text: String? {
        didSet {
            setUp()
        }
    }
    
    private var delegateWrapper: UITextFieldDelegateWrapper?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override func awakeFromNib() {
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
            super.text = text!.maskingString(mask: inputMask!, forwardDecoration: inputMaskForwardDecoration)
        }
    }
    
    var textWithoutMask: String? {
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
            textField.text = string.maskingString(mask: mask, forwardDecoration: inputMaskForwardDecoration)
            onValueChanged?()
            return false
        }
        
        //Проверяем, есть ли в изменяемом диапазоне значащие символы
        var rangeContainsNonMaskChars = false
        for i in range.location ..< (range.location + range.length) {
            if !mask.isDecorCharacter(at: i) {
                rangeContainsNonMaskChars = true
                break
            }
        }
        
        //Если в изменяемом диапазоне нет значащих символов - расширяем его влево(для удаления) или вправо(для вставки)
        var replacementRange = range
        if !rangeContainsNonMaskChars {
            while mask.isDecorCharacter(at: replacementRange.location) {
                if string == "" {
                    replacementRange.location -= 1
                } else {
                    replacementRange.location += 1
                }
                //Уперлись в маску в начале
                if replacementRange.location < 0 || replacementRange.location == 0 && mask.isDecorCharacter(at: replacementRange.location) {
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
            if !mask.isDecorCharacter(at: i) {
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
            if !mask.isDecorCharacter(at: i) {
                maxRawLength += 1
            }
        }
        
        if rawValue.length > maxRawLength {
            onValueChanged?()
            return false
        }
        
        //Накладываем маску и показываем получившееся значение в поле ввода
        let masked = rawValue.maskingString(mask: mask, forwardDecoration: inputMaskForwardDecoration)
        textField.text = masked
        
        //Расчитываем и задаем новое положение указателя
        //Сначала вычисляем, где бы находился курсор, если бы не было маски
        //При удалении (string == "") курсор остается в начале изменяемого диапазона. При вставке - смещается вправо на длину вставляемого текста
        let rawValueLengthBeforeCursor = string == "" ? rawValueRangeLocation : rawValueRangeLocation + string.length
        //Отрезаем значение без маски до расчитанного положения курсора
        let rawValueBeforeCursor = rawValue.substring(0, length: rawValueLengthBeforeCursor)
        //Накладываем на получившееся значение маску и вычисляем длину получившегося выражения
        let maskedRawValueBeforeCursor = rawValueBeforeCursor.maskingString(mask: mask, forwardDecoration: inputMaskForwardDecoration)
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
        guard let mask = mask, mask.length > 0 else {
            return maskedValue
        }
        
        var rawValue = ""
        
        for i in 0..<(maskedValue?.length ?? 0) {
            if !mask.isDecorCharacter(at: i) {
                rawValue.append(maskedValue!.substring(i, length: 1))
            }
        }
        
        return rawValue
    }
}

fileprivate extension UITextField {
    func setCursorPosition(_ position: Int) {
        let position = self.position(from: beginningOfDocument, offset: position)!
        selectedTextRange = textRange(from: position, to: position)
    }
}

fileprivate extension String {
    
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func isDecorCharacter(at position: Int) -> Bool {
        guard position < length else {
            return false
        }
        
        let MaskCharDigit = "9"
        let MaskCharLat = "L"
        let MaskCharCyr = "Б"
        let MaskCharAny = "S"
        
        let char = substring(position, length: 1)
        return ![MaskCharDigit, MaskCharLat, MaskCharCyr, MaskCharAny].contains(char)
    }
    
    func getNextDecorCharacter(from position: Int) -> String {
        guard position < self.characters.count else {
            return ""
        }
        
        var pos = position
        var decoration = ""
        while self.isDecorCharacter(at: pos) {
            let decorChar = substring(pos, length: 1)
            decoration.append(decorChar)
            pos = pos + 1
        }
        return decoration
    }
    
    func maskingString(mask: String, forwardDecoration: Bool = false) -> String {
        var formatted = ""
        for i in 0..<length {
            let previous = formatted
            let valueChar = substring(i, length: 1)
            formatted.append(mask.getNextDecorCharacter(from: formatted.characters.count))
            formatted.append(valueChar)
            if !formatted.checkForMask(mask) {
                formatted = previous
            } else if forwardDecoration {
                formatted.append(mask.getNextDecorCharacter(from: formatted.characters.count))
            }
        }
        return formatted
    }
    
    func checkForMask(_ mask: String) -> Bool {
        let MaskCharDigit = "9"
        let MaskCharLat = "L"
        let MaskCharCyr = "Б"
        let MaskCharAny = "S"
        
        for pos in 0..<length {
            guard pos < mask.length else {
                return false
            }
            
            let maskChar = mask.substring(pos, length: 1)
            let valueChar = substring(pos, length: 1)
            switch maskChar {
            case MaskCharDigit: if !valueChar.matchesToRegexp("[0-9]") {return false}
            case MaskCharLat: if !valueChar.matchesToRegexp("[A-Za-z]") {return false}
            case MaskCharCyr: if !valueChar.matchesToRegexp("[А-Яа-я]") {return false}
            case MaskCharAny: if !valueChar.matchesToRegexp(".") {return false}
            default: if(maskChar != valueChar) {return false}
            }
        }
        return true
    }
    
    func matchesToRegexp(_ regexp: String) -> Bool {
        return range(of: regexp, options: .regularExpression) != nil
    }
    
    func substring(_ startIndex: Int, length: Int) -> String {
        let start = self.characters.index(self.startIndex, offsetBy: startIndex)
        let end = self.characters.index(self.startIndex, offsetBy: startIndex + length)
        return self[start..<end]
    }
    
    mutating func replace(nsRange: NSRange, replacementString: String) {
        let nsString = self as NSString
        self = nsString.replacingCharacters(in: nsRange, with: replacementString)
    }
}


