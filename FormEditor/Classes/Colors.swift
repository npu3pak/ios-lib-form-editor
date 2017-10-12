import UIKit

extension UIColor {
    //Бирюзовый
    static var turquoise: UIColor {
        return UIColor(red: 0/255, green: 176/255, blue: 161/255, alpha: 1)
    }
}

struct Colors {
    struct InputAccessoryView {
        static let background = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        static let navigaionButton = UIColor.white
        static let doneButton = UIColor.turquoise
    }
}
