import UIKit

class ChatBubble: UIView {

    var chatImageView: UIImageView?
    var bgImageView: UIImageView?
    var text: String?
    var chatTextLabel: UILabel?
    var startY: CGFloat?
    var chatBubbleData: ChatBubbleData?
    var bubbleViewHeight: CGFloat = 0.0
    var bubbleViewWidth: CGFloat = 0.0
    
    init(data: ChatBubbleData, startY: CGFloat) {
        // 1. Initializing parent view with calculated frame
        self.startY = startY
        self.chatBubbleData = data
        super.init(frame: ChatBubble.framePrimary(data.sourceType, startY:startY))
        
//        self.backgroundColor = UIColor.redColor()
        
        let padding: CGFloat = 10.0
        
        // 2. Drawing image if any
        if let chatImage = data.image {
            let width: CGFloat = min(chatImage.size.width, self.frame.width - 2 * padding)
            let height: CGFloat = width * 0.5625 //maintaining the aspect ratio of an image
            self.chatImageView = UIImageView(frame: CGRectMake(padding, padding, width, height))
            self.chatImageView?.image = chatImage
            self.chatImageView?.layer.cornerRadius = 5.0
            self.chatImageView?.layer.masksToBounds = true
            self.addSubview(self.chatImageView!)
        }
        
        if data.text != "" {
            // frame calculation
            let startX = padding
            let startY:CGFloat = 5.0
            self.chatTextLabel = UILabel(frame: CGRectMake(startX, startY, self.frame.width - 2 * startX , 5))
            self.chatTextLabel?.textAlignment = data.sourceType == .Sender ? .Right : .Left
            self.chatTextLabel?.font = UIFont.systemFontOfSize(14)
            self.chatTextLabel?.numberOfLines = 0 // Making it multiline
            self.chatTextLabel?.text = data.text
            self.chatTextLabel?.sizeToFit() // Getting fullsize of it
            self.chatTextLabel?.backgroundColor = UIColor.greenColor()
            adjustStartXpos((self.chatTextLabel?.frame)!)
            self.addSubview(self.chatTextLabel!)
            
        }
        
        if data.audioMessageView != nil {
            bubbleViewHeight = (data.audioMessageView?.frame.height)! + padding
            bubbleViewWidth = (data.audioMessageView?.frame.width)! + padding * 2
        }
        
        // 4. Calculation of new width and height of the chat bubble view
        if self.chatImageView != nil {
            // Height calculation of the parent view depending upon the image view and text label
            bubbleViewWidth = CGRectGetMaxX(self.chatImageView!.frame) + padding
            bubbleViewHeight = CGRectGetMaxY(self.chatImageView!.frame) + padding
        } else if self.chatTextLabel != nil {
            bubbleViewHeight = CGRectGetMaxY(self.chatTextLabel!.frame) + padding / 2
            bubbleViewWidth = self.chatTextLabel!.frame.width + CGRectGetMinX(self.chatTextLabel!.frame) + padding
        }
        
        self.addImageBubble(data)
    }
 
    // 6. View persistance support
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - FRAME CALCULATION
    static func framePrimary(type:DataSourceType, startY: CGFloat) -> CGRect {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let maxWidth = screenSize.width * 0.55 // We are cosidering 65% of the screen width as the Maximum with of a single bubble
        let startX: CGFloat = type == .Sender ? screenSize.width  - maxWidth - 44 : 44
        return CGRectMake(startX, startY, maxWidth, 15) // 15 is the primary height before drawing starts
    }
    
    func adjustStartXpos(frameToAdjust: CGRect) {
        if (self.frame.width > frameToAdjust.width && self.chatBubbleData?.sourceType == .Sender) {
            self.center.x = self.center.x + (self.frame.width - frameToAdjust.width - 20)
        }
    }
    
    func addImageBubble(data: ChatBubbleData) {
        // 5. Adding new width and height of the chat bubble frame
        self.frame = CGRectMake(self.frame.minX, self.frame.minY, bubbleViewWidth, bubbleViewHeight)
        
        // 6. Adding the resizable image view to give it bubble like shape
        let bubbleImageFileName = data.sourceType == .Sender ? "bubbleMine" : "bubbleSomeone"
        bgImageView = UIImageView(frame: CGRectMake(0.0, 0.0, self.frame.width, self.frame.height))
        
        if data.sourceType == .Sender {
            bgImageView?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            bgImageView?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 22, 17, 28))
        }
        
        //  Frame recalculation for filling up the bubble with background bubble image
        let repsotionXFactor:CGFloat = data.sourceType == .Sender ? -1.0 : -8.0
        let bgImageNewX = CGRectGetMinX(bgImageView!.frame) + repsotionXFactor
        let bgImageNewWidth =  CGRectGetWidth(bgImageView!.frame) + CGFloat(12.0)
        let bgImageNewHeight =  CGRectGetHeight(bgImageView!.frame) + CGFloat(6.0)
        
        bgImageView?.frame = CGRectMake(bgImageNewX, 0.0, bgImageNewWidth, bgImageNewHeight)
        
        self.addSubview(bgImageView!)
        self.sendSubviewToBack(bgImageView!)
    }
    
}
