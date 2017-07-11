import UIKit

class FESection {
    var header: String?
    var footer: String?
    var params: Array<PFEParam>?
    
    init(header: String? = nil, footer: String? = nil, params: (() -> [PFEParam])? = nil) {
        self.header = header
        self.footer = footer
        self.params = params?()
    }
    
    subscript(index: Int) -> PFEParam? {
        guard index < params?.count ?? 0 else {
            return nil
        }
        
        return params?[index]
    }
    
    func contains(_ param: PFEParam) -> Bool {
        return params?.first(where: {$0.id == param.id}) != nil
    }

    //Такое заполнение секций иногда удобнее, чем заполнение в замыкании. Проект индексируется чуть быстрее.
    static func +=(left: FESection, right: PFEParam) {
        if left.params == nil {
            left.params = [PFEParam]()
        }
        
        left.params!.append(right)
    }
}
