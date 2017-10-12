import Foundation

// MARK: - Регулярные выражения

extension String {
    func checkRegexp(_ pattern: String) throws -> Bool {
        guard let range = self.range(of: pattern, options: .regularExpression) else {
            return false
        }
        
        return characters.count == characters.distance(from: range.lowerBound, to: range.upperBound)
    }
}

// MARK: - Подстроки

extension String {
    
    var length: Int {
        return self.characters.count
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

//// MARK: - Работа с масками

extension String {
    
    func applyingMask(_ mask: String?, forwardDecoration: Bool = false) -> String {
        guard let mask = mask else {
            return self
        }
        
        var formatted = ""
        for i in 0..<length {
            let previous = formatted
            let valueChar = substring(i, length: 1)
            formatted.append(mask.getNextMaskDecorCharacter(from: formatted.characters.count))
            formatted.append(valueChar)
            if !formatted.isConformToMask(mask) {
                formatted = previous
            } else if forwardDecoration {
                formatted.append(mask.getNextMaskDecorCharacter(from: formatted.characters.count))
            }
        }
        return formatted
    }
    
    func removingMask(_ mask: String?) -> String? {
        guard let mask = mask, mask.length > 0 else {
            return self
        }
        
        var rawValue = ""
        
        for i in 0..<length {
            if !mask.isMaskDecorCharacter(at: i) {
                rawValue.append(substring(i, length: 1))
            }
        }
        
        return rawValue
    }
    
    func isConformToMask(_ mask: String) -> Bool {
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
            case MaskCharDigit: if !(try! valueChar.checkRegexp("[0-9]")) {return false}
            case MaskCharLat: if !(try! valueChar.checkRegexp("[A-Za-z]")) {return false}
            case MaskCharCyr: if !(try! valueChar.checkRegexp("[А-Яа-я]")) {return false}
            case MaskCharAny: if !(try! valueChar.checkRegexp(".")) {return false}
            default: if(maskChar != valueChar) {return false}
            }
        }
        return true
    }
    
    func isMaskDecorCharacter(at position: Int) -> Bool {
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
    
    func getNextMaskDecorCharacter(from position: Int) -> String {
        guard position < self.characters.count else {
            return ""
        }
        
        var pos = position
        var decoration = ""
        while self.isMaskDecorCharacter(at: pos) {
            let decorChar = substring(pos, length: 1)
            decoration.append(decorChar)
            pos = pos + 1
        }
        return decoration
    }
}
