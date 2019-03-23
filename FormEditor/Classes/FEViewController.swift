import UIKit

open class FEViewController: UITableViewController, FormEditorFacadeDelegate {
    
    private var facade = FormEditorFacade()
    
    public weak var form: PFEForm? {
        didSet {
            facade.form = form
        }
    }
    
    public var preferences: FEPreferences {
        get { return facade.preferences }
        set { facade.preferences = newValue }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        facade.delegate = self
        
        tableView.estimatedRowHeight = 51
        tableView.rowHeight = UITableView.automaticDimension
    }

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return facade.visibleSectionsCount
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return facade.header(section: section)
    }
    
    override open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return facade.footer(section: section)
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facade.paramsCountInVisibleSection(section)
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = facade.cellReuseId(row: indexPath.row, section: indexPath.section)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) {
            facade.configure(cell: cell, row: indexPath.row, section: indexPath.section)
            return cell
        } else {
            let nibName = facade.cellNibName(row: indexPath.row, section: indexPath.section)
            let bundle = facade.cellNibBundle(row: indexPath.row, section: indexPath.section)
            let nib = UINib(nibName: nibName, bundle: bundle)
            tableView.register(nib, forCellReuseIdentifier: reuseId)
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) {
                facade.configure(cell: cell, row: indexPath.row, section: indexPath.section)
                return cell
            } else {
                print("Unable to find cell with reuse id \(reuseId)")
                return UITableViewCell()
            }
        }
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        facade.select(row: indexPath.row, section: indexPath.section)
    }
    
    public func reloadData() {
        tableView.reloadData()
    }
    
    public func refresh() {
        DispatchQueue.main.async {
            self.facade.refresh()
        }
    }
    
    public func select(row: Int, section: Int) {
        facade.select(row: row, section: section)
    }
    
    public func scrollTo(row: Int, section: Int) {
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
