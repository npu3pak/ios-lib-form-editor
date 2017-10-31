import Foundation

protocol FormParamFacadeDelegate: class {
    func beginEditing()
    func endEditing()
}

public class FormParamFacade {
    weak var delegate: FormParamFacadeDelegate?
    
    public var param: PFEParam
    private weak var formEditorFacade: FormEditorFacade?
    
    init(param: PFEParam, formEditorFacade: FormEditorFacade) {
        self.param = param
        self.formEditorFacade = formEditorFacade
    }
    
    public var isEditing = false
    
    // MARK: Управление жизненным циклом
    
    func beginEditing() {
        guard !isEditing else {
            return
        }
        
        isEditing = true
        delegate?.beginEditing()
    }
    
    func endEditing() {
        guard isEditing else {
            return
        }
        
        isEditing = false
        delegate?.endEditing()
    }
    
    // MARK: События редактора параметров
    
    public func didBeginEditing() {
        guard !isEditing else {
            return
        }
        
        isEditing = true
        formEditorFacade?.select(param: param, scrollToPosition: false)
    }
    
    public func didEndEditing() {
        guard isEditing else {
            return
        }
        
        isEditing = false
    }
    
    // MARK: Взаимодействие с другими параметрами
    
    var isPreviousParamExists: Bool {
        return formEditorFacade?.previous(param: param) != nil
    }
    
    var isNextParamExists: Bool {
        return formEditorFacade?.next(param: param) != nil
    }
    
    public var functionForMoveToNextParam: (()-> Void)? {
        guard isNextParamExists else {
            return nil
        }

        return editNextParam
    }
    
    public var functionForMoveToPreviousParam: (()-> Void)? {
        guard isPreviousParamExists else {
            return nil
        }
        
        return editPreviousParam
    }
    
    public func editPreviousParam() {
        if let previousParam = formEditorFacade?.previous(param: param) {
            formEditorFacade?.select(param: previousParam, scrollToPosition: true)
        } else {
            endEditing()
        }
    }
    
    public func editNextParam() {
        if let nextParam = formEditorFacade?.next(param: param) {
            formEditorFacade?.select(param: nextParam, scrollToPosition: true)
        } else {
            endEditing()
        }
    }
    
    // MARK: Стилизация
    
    public var preferences: FEPreferences {
        return formEditorFacade?.preferences ?? FEPreferences()
    }
}











