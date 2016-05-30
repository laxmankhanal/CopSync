import UIKit

class UILabelCustomization: UILabel {

    override func drawTextInRect(rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }

}
