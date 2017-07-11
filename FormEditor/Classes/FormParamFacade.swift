//
//  FormParamFacade.swift
//  FormEditor
//
//  Created by Evgeniy Safronov on 09.07.17.
//  Copyright © 2017 Evgeniy Safronov. All rights reserved.
//

import Foundation

public protocol FormParamFacadeDelegate: class {
    func beginEditing()
    func endEditing()
}

public class FormParamFacade {
    weak var delegate: FormParamFacadeDelegate?
    
    var param: PFEParam
    private weak var formEditorFacade: FormEditorFacade?
    
    init(param: PFEParam, formEditorFacade: FormEditorFacade) {
        self.param = param
        self.formEditorFacade = formEditorFacade
    }
    
    var isEditing = false
    
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
    
    func didBeginEditing() {
        guard !isEditing else {
            return
        }
        
        isEditing = true
        formEditorFacade?.select(param: param, scrollToPosition: false)
    }
    
    func didEndEditing() {
        guard isEditing else {
            return
        }
        
        isEditing = false
    }
    
    // MARK: Взаимодействие с другими параметрами
    
    func editPreviousParam() {
        if let previousParam = formEditorFacade?.previous(param: param) {
            formEditorFacade?.select(param: previousParam, scrollToPosition: true)
        } else {
            endEditing()
        }
    }
    
    func editNextParam() {
        if let nextParam = formEditorFacade?.next(param: param) {
            formEditorFacade?.select(param: nextParam, scrollToPosition: true)
        } else {
            endEditing()
        }
    }
}











