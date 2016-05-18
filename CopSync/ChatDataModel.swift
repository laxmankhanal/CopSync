import Foundation
import UIKit

enum DataSourceType: Int {
    case Mine = 0
    case Others
}

class ChatBubbleData {
    
    var text: String?
    var image: UIImage?
    var date: NSDate?
    var sourceType: DataSourceType
    var distance: Int?
    
    init(text: String, image: UIImage?, date: NSDate, sourceType: DataSourceType = .Mine, distance: Int) {
        self.text = text
        self.image = image
        self.date = date
        self.sourceType = sourceType
        self.distance = distance
    }
    
}
