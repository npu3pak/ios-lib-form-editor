//
//  FormEditorFacade.swift
//  FormEditor
//
//  Created by Evgeniy Safronov on 08.07.17.
//  Copyright © 2017 Evgeniy Safronov. All rights reserved.
//

import UIKit

protocol FormEditorFacadeDelegate: class {
    func scrollTo(row: Int, section: Int)
    
    func reload(indexPath: IndexPath)
    func reloadData()
    
    func beginUpdates()
    func endUpdates()
    
    func delete(indexPath: IndexPath)
    func insert(indexPath: IndexPath)
    func move(srcIndexPath: IndexPath, dstIndexPath: IndexPath)
    
    func insertSection(index: Int)
    func deleteSection(index: Int)
}

class FormEditorFacade {
    weak var delegate: FormEditorFacadeDelegate?
    
    private var visibleSections: [FESection] = []
    private var paramFacades: [String: FormParamFacade] = [:]
    
    var form: PFEForm? {
        didSet {
            let sections = form?.getSections() ?? []
            visibleSections = filterVisible(sections: sections)
            configureParamFacades(sections: sections)
            delegate?.reloadData()
        }
    }
    
    private func filterVisible(sections: [FESection]) -> [FESection] {
        var visibleSections = [FESection]()
        for section in sections {
            if let visibleParams = section.params?.filter({$0.isVisible()}), visibleParams.count > 0 {
                let visibleSection = FESection(header: section.header, footer: section.footer, params: {visibleParams})
                visibleSections.append(visibleSection)
            }
        }
        return visibleSections
    }
    
    private func configureParamFacades(sections: [FESection]) {
        paramFacades = [:]
        for section in sections {
            section.params?.forEach() {
                paramFacades[$0.id] = FormParamFacade(param: $0, formEditorFacade: self)
            }
        }
    }
    
    var visibleSectionsCount: Int {
        return visibleSections.count
    }
    
    func header(section: Int) -> String? {
        return visibleSections[section].header
    }
    
    func footer(section: Int) -> String? {
        return visibleSections[section].footer
    }
    
    func paramsCountInVisibleSection(_ section: Int) -> Int {
        return visibleSections[section].params?.count ?? 0
    }
    
    func cellReuseId(row: Int, section: Int) -> String {
        return visibleSections[section][row]?.cellReuseId ?? ""
    }
    
    func cellNibName(row: Int, section: Int) -> String {
        guard let param = visibleSections[section][row] else {
            return ""
        }
        
        return param.cellNibName
    }
    
    func paramFacade(row: Int, section: Int) -> FormParamFacade? {
        guard let param = visibleSections[section][row] else {
            return nil
        }
        
        return paramFacades[param.id]
    }
    
    func indexPath(param: PFEParam) -> IndexPath? {
        for section in 0..<visibleSections.count {
            for row in 0..<(visibleSections[section].params?.count ?? 0) {
                if visibleSections[section][row]?.id == param.id {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
    
    func indexPath(param: PFEParam, sections: [FESection]) -> IndexPath? {
        for section in 0..<sections.count {
            for row in 0..<(sections[section].params?.count ?? 0) {
                if sections[section][row]?.id == param.id {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
    
    func configure(cell: UITableViewCell, row: Int, section: Int) {
        guard let param = visibleSections[section][row] else {
            return
        }
        
        guard let facade = paramFacades[param.id] else {
            return
        }
        
        param.configure(cell: cell, facade: facade)
    }
    
    func select(row: Int, section: Int) {
        guard let param = visibleSections[section][row] else {
            return
        }
        
        select(param: param, scrollToPosition: true)
    }
    
    func select(param: PFEParam, scrollToPosition: Bool) {
        param.select()
        
        guard param.canReceiveFocus else {
            return
        }
        
        guard let facade = paramFacades[param.id], facade.isEditing == false else {
            return
        }
        
        paramFacades.values.forEach() {
            if $0.isEditing {
                $0.endEditing()
            }
        }
        
        facade.beginEditing()
        
        if scrollToPosition {
            if let paramIndexPath = indexPath(param: param) {
                delegate?.scrollTo(row: paramIndexPath.row, section: paramIndexPath.section)
            }
        }
    }
    
    func next(param: PFEParam) -> PFEParam? {
        var awaitNextParam = false
        for section in visibleSections {
            for p in section.params ?? [] {
                if awaitNextParam && p.canReceiveFocus {
                    return p
                }
                if param.id == p.id {
                    awaitNextParam = true
                }
            }
        }
        return nil
    }
    
    func previous(param: PFEParam) -> PFEParam? {
        var previousParam: PFEParam?
        for section in visibleSections {
            for p in section.params ?? [] {
                if param.id == p.id {
                    return previousParam
                } else if p.canReceiveFocus {
                    previousParam = p
                }
            }
        }
        return previousParam
    }
    
    func param(id: String, sections: [FESection]) -> PFEParam? {
        for section in sections {
            for param in section.params ?? [] {
                if param.id == id {
                    return param
                }
            }
        }
        return nil
    }
    
    func refresh() {
        guard let delegate = delegate else {
            return
        }
        let oldSections = visibleSections
        let newSections = filterVisible(sections: form?.getSections() ?? [])
        
        let addedItems = self.addedItems(oldSections: oldSections, newSections: newSections)
        let deletedItems = self.deletedItems(oldSections: oldSections, newSections: newSections)
        let movedItems = self.movedItems(oldSections: oldSections, newSections: newSections)
        let updatedItems = self.updatedItems(oldSections: oldSections, newSections: newSections)
        
        let addedSections = self.addedSections(oldSections: oldSections, newSections: newSections)
        let deletedSections = self.deletedSections(oldSections: oldSections, newSections: newSections)
        
        visibleSections = newSections
        
        delegate.beginUpdates()
        
        addedSections.forEach({delegate.insertSection(index:$0)})
        deletedSections.forEach({delegate.deleteSection(index:$0)})
        deletedItems.forEach({delegate.delete(indexPath: $0)})
        addedItems.forEach({delegate.insert(indexPath: $0)})
        movedItems.forEach({delegate.move(srcIndexPath: $0.0, dstIndexPath: $0.1)})
        
        for facade in paramFacades.values {
            if let param = self.param(id: facade.param.id, sections: newSections) {
                facade.param = param
            }
        }
        updatedItems.forEach({delegate.reload(indexPath: $0)})
        
        delegate.endUpdates()
    }
    
    
    
    private func addedSections(oldSections: [FESection], newSections: [FESection]) -> [Int] {
        guard newSections.count > oldSections.count else {
            return []
        }
        
        var sections = [Int]()
        for i in oldSections.count..<newSections.count {
            sections.append(i)
        }
        return sections
    }
    
    private func deletedSections(oldSections: [FESection], newSections: [FESection]) -> [Int] {
        guard newSections.count < oldSections.count else {
            return []
        }
        
        var sections = [Int]()
        for i in newSections.count..<oldSections.count {
            sections.append(i)
        }
        return sections
    }
    
    private func addedItems(oldSections: [FESection], newSections: [FESection]) -> [IndexPath] {
        var addedItems: [IndexPath] = []
        //Параметры, которые есть только в new
        for newSection in newSections {
            for param in newSection.params ?? [] {
                var isAddedParam = true
                for oldSection in oldSections {
                    if oldSection.contains(param) {
                        isAddedParam = false
                        break
                    }
                }
                if isAddedParam {
                    if let indexPath = indexPath(param: param, sections: newSections) {
                        addedItems.append(indexPath)
                    }
                }
            }
        }
        return addedItems
    }
    
    private func deletedItems(oldSections: [FESection], newSections: [FESection]) -> [IndexPath] {
        var deletedItems: [IndexPath] = []
        //Параметры, которые есть только в old
        for oldSection in oldSections {
            for param in oldSection.params ?? [] {
                var isDeletedParam = true
                for newSection in newSections {
                    if newSection.contains(param) {
                        isDeletedParam = false
                        break
                    }
                }
                if isDeletedParam {
                    if let indexPath = indexPath(param: param, sections: oldSections) {
                        deletedItems.append(indexPath)
                    }
                }
            }
        }
        return deletedItems
    }
    
    private func movedItems(oldSections: [FESection], newSections: [FESection]) -> [(IndexPath, IndexPath)] {
        var movedItems: [(IndexPath, IndexPath)] = []
        for oldSection in oldSections {
            for newSection in newSections {
                for param in newSection.params ?? [] {
                    if oldSection.contains(param) {
                        let oldPath = self.indexPath(param: param, sections: oldSections)
                        let newPath = self.indexPath(param: param, sections: newSections)
                        if oldPath != nil && newPath != nil && oldPath != newPath {
                            movedItems.append((oldPath!, newPath!))
                        }
                    }
                }
            }
        }
        return movedItems
    }
    
    private func updatedItems(oldSections: [FESection], newSections: [FESection]) -> [IndexPath] {
        var updatedItems: [IndexPath] = []
        for oldSection in oldSections {
            for newSection in newSections {
                for newParam in newSection.params ?? [] {
                    if oldSection.contains(newParam) {
                        let oldPath = self.indexPath(param: newParam, sections: oldSections)
                        let newPath = self.indexPath(param: newParam, sections: newSections)
                        
                        if oldPath != nil && newPath != nil && oldPath == newPath {
                            if let oldParam = oldSections[oldPath!.section][oldPath!.row] {
                                if !newParam.equals(other: oldParam) {
                                    let facade = self.paramFacade(row: newPath!.row, section: newPath!.section)
                                    //Еслиобновлять во время редактирования - будет теряться firstResponder
                                    if !(facade?.isEditing ?? false) {
                                        updatedItems.append(newPath!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return updatedItems
    }
}













