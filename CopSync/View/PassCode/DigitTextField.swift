import UIKit

class DigitTextField: UITextField {
    
    override func deleteBackward() {
        NSNotificationCenter.defaultCenter().postNotificationName("deletePressed", object: nil)
//        super.deleteBackward()
    }
}
