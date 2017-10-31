import UIKit

extension UITextField {
    func enableParamsNavigationToolbar(preferences: FEPreferences, moveNextClosure: (() -> Void)?, movePreviousClosure: (() -> Void)?) {
        self.inputAccessoryView = navigationToolbar(target: self, preferences: preferences, onDoneButtonClick: #selector(onDoneButtonClick), moveNextClosure: moveNextClosure, movePreviousClosure: movePreviousClosure)
    }
    
    @objc private func onDoneButtonClick() {
        _ = resignFirstResponder()
    }
}

extension UITextView {
    func enableParamsNavigationToolbar(preferences: FEPreferences, moveNextClosure: (() -> Void)?, movePreviousClosure: (() -> Void)? ) {
        self.inputAccessoryView = navigationToolbar(target: self, preferences: preferences, onDoneButtonClick: #selector(onDoneButtonClick), moveNextClosure: moveNextClosure, movePreviousClosure: movePreviousClosure)
    }
    
    @objc private func onDoneButtonClick() {
        _ = resignFirstResponder()
    }
}

fileprivate func navigationToolbar(target: Any, preferences: FEPreferences, onDoneButtonClick: Selector, moveNextClosure: (() -> Void)?, movePreviousClosure: (() -> Void)? ) -> UIToolbar {
    // Отступы
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    fixedSpace.width = 16
    
    // Навигация
    let navigation = NavigationButtons(preferences: preferences, moveNextClosure: moveNextClosure, movePreviousClosure: movePreviousClosure)
    navigation.tintColor = preferences.colors.inputAccessory.navigation
    let segmentButton = UIBarButtonItem(customView: navigation)
    
    // Готово
    let doneButton = UIBarButtonItem(title: preferences.labels.inputAccessory.done, style: .done, target: target, action: onDoneButtonClick)
    doneButton.tintColor = preferences.colors.inputAccessory.done
    
    // Панель
    let toolbar = UIToolbar()
    toolbar.items = [segmentButton, flexibleSpace, doneButton]
    toolbar.sizeToFit()
    toolbar.isTranslucent = false
    toolbar.barTintColor = preferences.colors.inputAccessory.background
    return toolbar
}

fileprivate class NavigationButtons: UISegmentedControl {
    private var moveNextClosure:  (() -> Void)?
    private var moveNextClosureIndex: Int?
    private var movePreviousClosure: (() -> Void)?
    private var movePreviousClosureIndex: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(preferences: FEPreferences, moveNextClosure:  (() -> Void)?, movePreviousClosure: (() -> Void)?) {
        var items: [Any] = []
        
        if movePreviousClosure != nil {
            items.append(preferences.labels.inputAccessory.back)
        }
        if moveNextClosure != nil {
            items.append(preferences.labels.inputAccessory.forward)
        }
        
        super.init(items: items)
        
        if movePreviousClosure != nil {
            movePreviousClosureIndex = 0
            self.movePreviousClosure = movePreviousClosure
        }
        if moveNextClosure != nil {
            moveNextClosureIndex = items.count - 1
            self.moveNextClosure = moveNextClosure
        }

        addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }
    
    func onValueChanged() {
        if selectedSegmentIndex == movePreviousClosureIndex {
            movePreviousClosure?()
        }
        
        if selectedSegmentIndex == moveNextClosureIndex {
            moveNextClosure?()
        }
        
        selectedSegmentIndex = -1
    }
}

