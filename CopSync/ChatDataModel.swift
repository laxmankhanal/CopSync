import Foundation
import UIKit

enum DataSourceType: Int {
    case Sender = 0
    case Receiver
}

class ChatBubbleData {
    
    var text: String?
    var image: UIImage?
    var sourceType: DataSourceType
    
    init(text: String, image: UIImage?, sourceType: DataSourceType = .Sender) {
        self.text = text
        self.image = image
        self.sourceType = sourceType
    }
    
}

class MessageInfoData {

    var distance: Float?
    var time: String
    var sourceType: DataSourceType
    
    init(distance: Float, time: String, sourceType: DataSourceType = .Sender) {
        self.distance = distance
        self.time = time
        self.sourceType = sourceType
    }
    
}
