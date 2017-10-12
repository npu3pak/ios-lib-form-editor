//
//  ViewController.swift
//  FormEditor
//
//  Created by npu3pak on 07/11/2017.
//  Copyright (c) 2017 npu3pak. All rights reserved.
//

import UIKit
import FormEditor

class ViewController: FormEditorViewController, PFEForm {
    
    var secondVisible = false
    
    var value1: String?
    var value2: String?
    
    var date1: Date?
    var date2: Date?
    
    var selector1: String?
    var selector2: String?
    let selectorValues: [(String?, String?)] = [("1","Раз"),("2","Два"),("3","Три")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form = self
    }
    
    func getSections() -> [FESection] {
        let section1 = FESection(header: "Хэдер")
        section1 += FEText(id: "text_1", title: "Текст 1", value: value1, inputMask: "SSSS") {self.value1 = $0; self.refresh()}
        section1 += FEDate(id: "date_1", title: "Дата 1", value: date1, minDate: Date(), maxDate: Date()) {self.date1 = $0; self.refresh()}
        
//        section1 += FESelector(id: "sel_1", title: "Выбор 1", value: selector1, readOnly: false, listener: {self.selector1 = $0; self.refresh()}, items: {self.selectorValues})
        
        for i in 1...2 {
            section1 += FECustom(id: "Custom\(i)", reuseId: "Cell", onSelect: {print("\(i)")})
        }
        
        
        let section2 = FESection(footer: "Футер")
        section2 += FEText(id: "text_2", title: "Текст 2", value: value2, visible: (value1?.characters.count ?? 0 > 0)) {self.value2 = $0}
        section2 += FEDate(id: "date_2", title: "Дата 2", value: date2, minDate: Date(), maxDate: Date(), visible: (self.date1 != nil && date1! < Date())) {self.date2 = $0}
//        section2 += FESelector(id: "sel_2", title: "Выбор 2", value: selector1, readOnly: false, visible: selector1 == "3",listener: {self.selector2 = $0}, items: {self.selectorValues})
        return [section1, section2]
    }
    
    @IBAction func switchParamVisibility(_ sender: Any) {
        secondVisible = !secondVisible
        refresh()
    }
}

