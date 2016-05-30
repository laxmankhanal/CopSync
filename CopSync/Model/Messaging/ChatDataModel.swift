import Foundation
import UIKit

enum DataSourceType: Int {
    case Sender = 0
    case Receiver
}

class ChatBubbleData {
    
    var text: String?
    var image: UIImage?
    var audioMessageView: UIView?
    var sourceType: DataSourceType
    
    init(text: String, image: UIImage?, sourceType: DataSourceType = .Sender, audioMessageView: UIView?) {
        self.text = text
        self.image = image
        self.audioMessageView = audioMessageView
        self.sourceType = sourceType
    }
    
}

class MessageInfoData {

    var distance: String
    var time: String
    var sourceType: DataSourceType
    var officerName: String
    
    init(distance: Float, time: String, sourceType: DataSourceType = .Sender, officerName: String) {
        self.distance = String(distance)
        self.time = time
        self.sourceType = sourceType
        self.officerName = officerName
    }
    
}
