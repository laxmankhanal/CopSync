import UIKit

enum MessageType: String {
    case Text = "Text"
    case Audio = "Audio"
}

class ViewController: UIViewController {
    
    enum ImageSource: String {
        case Camera = "Camera"
        case PhotoLibrary = "PhotoLibrary"
    }
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint! //which element's constaint?
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var audioMessageButton: UIButton!
    @IBOutlet var dummyBottomConstraint: NSLayoutConstraint!// same here

    var imageSourceType: ImageSource?
    var chatBubbleData: ChatBubbleData?
    var chatBubble: ChatBubble?
    var messageInfoDataSender: MessageInfoData?
    var messageInfoLabel: UILabel?
    var messageMaxY: CGFloat = 10.0
    var imagePickerController = UIImagePickerController()
    var messageSourceImageView: UIImageView?
    var screenSize: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.mainScreen().bounds
        self.imagePickerController.delegate = self
        
        // notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);

        // Adding an out going chat bubble
        self.chatBubbleData = ChatBubbleData(text: "", image: UIImage(named: "chatImage")!, sourceType: .Receiver)
        self.chatBubble = ChatBubble(data: chatBubbleData!, startY: 50)
        self.mainScrollView.addSubview(chatBubble!)
        
        self.messageMaxY = (chatBubble?.frame.maxY)!
        self.mainScrollView.addSubview(self.messageSourceImage((chatBubble?.frame.minY)!))
        self.messageTextField.text = ""
        
//        // Adding an incoming chat bubble
//        var chatBubbleDataOpponent = ChatBubbleData(text: "Fine bro!!! check this out", image: UIImage(named: "chatImage")!, sourceType: .Receiver)
//        var chatBubbleOpponent = ChatBubble(data: chatBubbleDataOpponent, startY: self.chatBubbleSender!.frame.maxY + 10)
//        self.mainScrollView.addSubview(chatBubbleOpponent)

    }
    
//    MARK:- Keyboard notification
    func keyboardWillShow(sender: NSNotification) {
        adjustHeight(true, notification: sender)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        adjustHeight(false, notification: sender)
    }
    
    // Adjust bottom constraint of the view for typing message according to keyboard status.
    func adjustHeight(showKeyboard: Bool, notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()//?)!.CGRectValue()
        let changeInHeight = keyboardFrame.height * (showKeyboard ? 1 : -1)
        self.bottomConstraint.constant += changeInHeight
        self.view.layoutIfNeeded()
        
        switch showKeyboard {
        case true:
            if self.messageMaxY > self.screenSize?.height {
                self.mainScrollView.contentOffset.y = keyboardFrame.height
            }
        
        case false:
            self.mainScrollView.contentOffset.y = 0
        }
    }
    
    @IBAction func sendButtonAction(sender: UIButton) { // which button?
        switch MessageType(rawValue: (sender.titleLabel?.text)!)! as MessageType {
        case .Audio:
            print("record audio")
            
        case .Text:
            self.view.endEditing(true)
            self.chatBubbleData = ChatBubbleData(text: self.messageTextField.text!, image: nil, sourceType: .Sender)
            self.chatBubble = ChatBubble(data: chatBubbleData!, startY: self.messageMaxY + 20)
            self.mainScrollView.addSubview(chatBubble!)
            
            self.messageMaxY = (chatBubble?.frame.maxY)!
            self.mainScrollView.addSubview(self.messageSourceImage((chatBubble?.frame.minY)!))
            self.messageTextField.text = ""
            self.messageInfoDataSender = MessageInfoData(distance: 10, time: dateComponents(NSDate()), sourceType: .Sender)
            self.addMessageInfoLabel(messageMaxY + 10, parentView: self.mainScrollView)
        }
    }
    
    @IBAction func takeImageButtonAction(sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Select image source", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cameraAction = UIAlertAction(title: ImageSource.Camera.rawValue, style: UIAlertActionStyle.Default, handler: {
            action in
                self.pickImageFrom(ImageSource.Camera)
        })
        
        let galleryAction = UIAlertAction(title: ImageSource.PhotoLibrary.rawValue, style: UIAlertActionStyle.Default, handler: {
            action in
                self.pickImageFrom(ImageSource.PhotoLibrary)
        })
        
        let cancelAction  = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            action in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func pickImageFrom(imageSource: ImageSource) {
        self.imagePickerController.allowsEditing = false
        
        if (imageSource == .Camera && UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            self.imagePickerController.sourceType = .Camera
        } else {
            self.imagePickerController.sourceType = .PhotoLibrary
        }
        self.presentViewController(self.imagePickerController, animated: true, completion: nil)
    }
    
    func sendImageMessage(imageMessage: UIImage) {
        self.chatBubbleData = ChatBubbleData(text: "", image: imageMessage , sourceType: .Sender)
        self.chatBubble = ChatBubble(data: chatBubbleData!, startY: self.messageMaxY + 20)
        self.mainScrollView.addSubview(chatBubble!)
        self.mainScrollView.addSubview(self.messageSourceImage((chatBubble?.frame.minY)!))
        self.messageMaxY = (self.chatBubble?.frame.maxY)!
        self.messageInfoDataSender = MessageInfoData(distance: 10, time: dateComponents(NSDate()) , sourceType: .Sender)
        self.addMessageInfoLabel(messageMaxY + 10, parentView: self.mainScrollView)


    }
    
    func addMessageInfoLabel(startY: CGFloat, parentView: UIView) {
        self.messageInfoLabel = UILabel(frame: ChatBubble.framePrimary(.Sender, startY: startY))
        self.messageInfoLabel?.text = String(messageInfoDataSender?.distance!) + (messageInfoDataSender?.time)!
        self.messageInfoLabel?.font = self.messageInfoLabel?.font.fontWithSize(10)
        parentView.addSubview(messageInfoLabel!)
        self.messageMaxY = (messageInfoLabel?.frame.maxY)!
        self.dummyBottomConstraint.constant = self.messageMaxY + 10
        self.scrollToBottom()
    }
    
    func dateComponents(date: NSDate) -> String {
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Hour, .Minute] , fromDate: date)
        var hour = components.hour
        let min = components.minute
        var amPm = "AM"
        if hour >= 12 {
            if min > 0 {
                amPm = "PM"
                hour = (hour - 12)
                
                if hour == 0 {
                    hour = 12
                }
            }
        }
        return ( String(hour) + " : " + String (min) + " " + amPm )
    }
    
    func scrollToBottom() {
        self.mainScrollView.contentOffset = CGPoint(x: 0, y: self.messageMaxY)
    }
    
    func messageSourceImage(yMinPosition: CGFloat) -> UIImageView {
        let xPosition: CGFloat =  self.chatBubbleData?.sourceType == .Sender ? self.screenSize!.width - 20 : 10
        self.messageSourceImageView = UIImageView(frame: CGRect(x: xPosition, y: yMinPosition, width: 20, height: 20))
        let actorImage = UIImage(
        self.messageSourceImageView?.image
        return self.messageSourceImageView!
    }

}

extension ViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        self.audioMessageButton.setTitle("Text", forState: .Normal)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.audioMessageButton.setTitle("Audio", forState: .Normal)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendImageMessage(pickedImage);
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}