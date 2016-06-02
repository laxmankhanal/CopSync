import Foundation
import UIKit

//class CircularView {
//    
//    static func createCircularView(view: UIView)  {
//        let circularView = view
//        circularView.layer.cornerRadius = circularView.frame.width / 2
//        circularView.clipsToBounds = true
//    }
//    
//    static func removeCircularView(view: UIView) {
//        view.frame.size.height = 3
//        view.center.y = view.superview!.frame.height / 2
//        view.clipsToBounds = false
//    }
//    
//}

extension UIView {
    func createCircularView()  {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
    func removeCircularView() {
        self.frame.size.height = 3
        self.center.y = self.superview!.frame.height / 2
        self.clipsToBounds = false
    }
}
