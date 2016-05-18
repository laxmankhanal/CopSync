import UIKit

class ChatBubble: UIView {

    var chatImageView: UIImageView?
    var bgImageView: UIImageView?
    var text: String?
    var chatTextLabel: UILabel?
    
    init(data: ChatBubbleData, startY: CGFloat){
        
        // 1. Initializing parent view with calculated frame
        super.init(frame: ChatBubble.framePrimary(data.sourceType, startY:startY))
        
        // Making Background color as gray color
//        self.backgroundColor = UIColor.lightGrayColor()
        
        let padding: CGFloat = 10.0
        
        // 2. Drawing image if any
        if let chatImage = data.image {
            
            let width: CGFloat = min(chatImage.size.width, self.frame.width - 2 * padding)
            let height: CGFloat = width * 0.5625 //maintaining the aspect ratio of an image
            chatImageView = UIImageView(frame: CGRectMake(padding, padding, width, height))
            chatImageView?.image = chatImage
            chatImageView?.layer.cornerRadius = 5.0
            chatImageView?.layer.masksToBounds = true
            self.addSubview(chatImageView!)
        }
        
        if let chatText = data.text {
            // frame calculation
            let startX = padding
            var startY:CGFloat = 5.0
            if let imageView = chatImageView {
                startY += self.chatImageView!.frame.maxY
            }
            chatTextLabel = UILabel(frame: CGRectMake(startX, startY, self.frame.width - 2 * startX , 5))
            chatTextLabel?.textAlignment = data.sourceType == .Mine ? .Right : .Left
            chatTextLabel?.font = UIFont.systemFontOfSize(14)
            chatTextLabel?.numberOfLines = 0 // Making it multiline
            chatTextLabel?.text = data.text
            chatTextLabel?.sizeToFit() // Getting fullsize of it
            self.addSubview(chatTextLabel!)
        }
        // 4. Calculation of new width and height of the chat bubble view
        var bubbleViewHeight: CGFloat = 0.0
        var bubbleViewWidth: CGFloat = 0.0
        if let imageView = chatImageView {
            // Height calculation of the parent view depending upon the image view and text label
            bubbleViewWidth = max(self.chatImageView!.frame.maxX, self.chatTextLabel!.frame.maxX) + padding
            bubbleViewHeight = max(self.chatImageView!.frame.maxY, self.chatTextLabel!.frame.maxY) + padding
            
        } else {
            bubbleViewHeight = self.chatTextLabel!.frame.maxY + padding/2
            bubbleViewWidth = self.chatTextLabel!.frame.width + self.chatTextLabel!.frame.minX + padding
        }
        
        // 5. Adding new width and height of the chat bubble frame
        
        self.frame = CGRectMake(self.frame.minX, self.frame.minY, bubbleViewWidth, bubbleViewHeight)
        
        // 6. Adding the resizable image view to give it bubble like shape
        let bubbleImageFileName = data.sourceType == .Mine ? "bubbleMine" : "bubbleSomeone"
        bgImageView = UIImageView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)))
        if data.sourceType == .Mine {
            bgImageView?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            bgImageView?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 22, 17, 28))
        }
        
       //  Frame recalculation for filling up the bubble with background bubble image
        let repsotionXFactor:CGFloat = data.sourceType == .Mine ? -1.0 : -8.0
        let bgImageNewX = CGRectGetMinX(bgImageView!.frame) + repsotionXFactor
        let bgImageNewWidth =  CGRectGetWidth(bgImageView!.frame) + CGFloat(12.0)
        let bgImageNewHeight =  CGRectGetHeight(bgImageView!.frame) + CGFloat(6.0)
        bgImageView?.frame = CGRectMake(bgImageNewX, 0.0, bgImageNewWidth, bgImageNewHeight)
        
        self.addSubview(bgImageView!)
        self.sendSubviewToBack(bgImageView!)
    }
 
    // 6. View persistance support
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }

    //MARK: - FRAME CALCULATION
    class func framePrimary(type:DataSourceType, startY: CGFloat) -> CGRect{
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let paddingFactor: CGFloat = 0.02
        let sidePadding = screenSize.width * paddingFactor
        let maxWidth = screenSize.width * 0.65 // We are cosidering 65% of the screen width as the Maximum with of a single bubble
        let startX: CGFloat = type == .Mine ? screenSize.width * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRectMake(startX, startY, maxWidth, 5) // 5 is the primary height before drawing starts
    }
    
    
}
