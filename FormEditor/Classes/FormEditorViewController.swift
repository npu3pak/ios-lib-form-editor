//
//  FormEditorViewController.swift
//  FormEditor
//
//  Created by Evgeniy Safronov on 08.07.17.
//  Copyright © 2017 Evgeniy Safronov. All rights reserved.
//

import UIKit

class FormEditorViewController: UITableViewController, FormEditorFacadeDelegate {
    
    private var facade = FormEditorFacade()
    
    var form: PFEForm? {
        didSet {
            facade.form = form
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        facade.delegate = self
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return facade.visibleSectionsCount
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return facade.header(section: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return facade.footer(section: section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facade.paramsCountInVisibleSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = facade.cellReuseId(row: indexPath.row, section: indexPath.section)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) {
            facade.configure(cell: cell, row: indexPath.row, section: indexPath.section)
            return cell
        } else {
            let nibName = facade.cellNibName(row: indexPath.row, section: indexPath.section)
            let nib = UINib(nibName: nibName, bundle: Bundle(for: FormEditorViewController.self))
            tableView.register(nib, forCellReuseIdentifier: reuseId)
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) {
                facade.configure(cell: cell, row: indexPath.row, section: indexPath.section)
                return cell
            } else {
                print("Не удалось найти ячейку \(reuseId)")
                return UITableViewCell()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        facade.select(row: indexPath.row, section: indexPath.section)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func refresh() {
        DispatchQueue.main.async {
            self.facade.refresh()
        }
    }
    
    func select(row: Int, section: Int) {
        facade.select(row: row, section: section)
    }
    
    func scrollTo(row: Int, section: Int) {
        let indexPath = IndexPath(row: row, section: section)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    func beginUpdates() {
        tableView.beginUpdates()
    }
    
    func endUpdates() {
        tableView.endUpdates()
    }
    
    func delete(indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func insert(indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func move(srcIndexPath: IndexPath, dstIndexPath: IndexPath) {
        tableView.moveRow(at: srcIndexPath, to: dstIndexPath)
    }
    
    func insertSection(index: Int) {
        tableView.insertSections([index], with: .fade)
    }
    
    func deleteSection(index: Int) {
        tableView.deleteSections([index], with: .fade)
    }
    
    func reload(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
