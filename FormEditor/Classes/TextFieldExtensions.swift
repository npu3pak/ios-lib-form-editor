import UIKit

public extension UITextField {
    
    public func enableParamsNavigationToolbar(moveNextClosure:  @escaping (() -> Void), movePreviousClosure: @escaping (() -> Void)) {
        // Отступы
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Навигация
        let navigation = NavigationButtons(moveNextClosure: moveNextClosure, movePreviousClosure: movePreviousClosure)
        navigation.tintColor = Colors.InputAccessoryView.navigaionButton
        let segmentButton = UIBarButtonItem(customView: navigation)
        
        // Готово
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(onDoneButtonClick))
        doneButton.tintColor = Colors.InputAccessoryView.doneButton
        
        // Панель
        let toolbar = UIToolbar()
        toolbar.items = [segmentButton, flexibleSpace, doneButton]
        toolbar.sizeToFit()
        toolbar.isTranslucent = false
        toolbar.barTintColor = Colors.InputAccessoryView.background
        self.inputAccessoryView = toolbar
    }
    
    @objc private func onDoneButtonClick() {
        _ = resignFirstResponder()
    }
}

fileprivate class NavigationButtons: UISegmentedControl {
    private var moveNextClosure:  (() -> Void)?
    private var movePreviousClosure: (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(moveNextClosure:  @escaping (() -> Void), movePreviousClosure: @escaping (() -> Void)) {
        super.init(items: ["Назад", "Вперед"])
        self.movePreviousClosure = movePreviousClosure
        self.moveNextClosure = moveNextClosure
        
        addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }
    
    func onValueChanged() {
        if selectedSegmentIndex == 0 {
            movePreviousClosure?()
        }
        
        if selectedSegmentIndex == 1 {
            moveNextClosure?()
        }
        
        selectedSegmentIndex = -1
    }
}
