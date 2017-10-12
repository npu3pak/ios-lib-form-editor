import UIKit

public class FETextView: UITextView {
    
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
                                               name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public var font: UIFont? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public var contentInset: UIEdgeInsets {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public var textAlignment: NSTextAlignment {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public var text: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func textChanged(_ notification: Notification) {
        setNeedsDisplay()
        self.onTextChanged?()
    }
    
    override public func draw(_ rect: CGRect) {
        if text!.isEmpty && !placeholderText.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            let attributes: [ String: AnyObject ] = [
                NSFontAttributeName : font!,
                NSForegroundColorAttributeName : placeholderColor,
                NSParagraphStyleAttributeName  : paragraphStyle]
            
            placeholderText.draw(in: placeholderRectForBounds(bounds), withAttributes: attributes)
        }
        super.draw(rect)
    }
    
    func placeholderRectForBounds(_ bounds: CGRect) -> CGRect {
        var x = contentInset.left + 4.0
        var y = contentInset.top  + 9.0
        let w = frame.size.width - contentInset.left - contentInset.right - 16.0
        let h = frame.size.height - contentInset.top - contentInset.bottom - 16.0
        
        if let style = self.typingAttributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
            x += style.headIndent
            y += style.firstLineHeadIndent
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
