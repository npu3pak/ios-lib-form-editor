import UIKit

open class FETextView: UITextView {
    
    public var onTextChanged: (()->Void)?
    
    @IBInspectable public var placeholderColor: UIColor = UIColor(red: 200/255, green: 201/255, blue: 206/255, alpha: 1)
    @IBInspectable public var placeholderText: String = ""
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUp()
    }
    
    private func setUp() {
        NotificationCenter.default.addObserver(self, selector: #selector(FETextView.textChanged(_:)),
                                               name: UITextView.textDidChangeNotification, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open var font: UIFont? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open var contentInset: UIEdgeInsets {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open var text: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc func textChanged(_ notification: Notification) {
        setNeedsDisplay()
        self.onTextChanged?()
    }
    
    override open func draw(_ rect: CGRect) {
        if text!.isEmpty && !placeholderText.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            let attributes: [ String: AnyObject ] = [
                convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font!,
                convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : placeholderColor,
                convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle)  : paragraphStyle]
            
            placeholderText.draw(in: placeholderRectForBounds(bounds), withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
        }
        super.draw(rect)
    }
    
    func placeholderRectForBounds(_ bounds: CGRect) -> CGRect {
        var x = contentInset.left + 4.0
        var y = contentInset.top  + 9.0
        let w = frame.size.width - contentInset.left - contentInset.right - 16.0
        let h = frame.size.height - contentInset.top - contentInset.bottom - 16.0
        
        if let style = convertFromNSAttributedStringKeyDictionary(self.typingAttributes)[convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle)] as? NSParagraphStyle {
            x += style.headIndent
            y += style.firstLineHeadIndent
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
