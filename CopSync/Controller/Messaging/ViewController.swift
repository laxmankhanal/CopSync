import UIKit
import AVFoundation

enum MessageType: String {
    case Text = "Text"
    case Audio = "Audio"
    case Recording = "Recording"
}

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    enum ImageSource: String {
        case Camera = "Camera"
        case PhotoLibrary = "PhotoLibrary"
    }
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint! //which element's constaint?
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var audioMessageButton: UIButton!
    @IBOutlet var dummyBottomConstraint: NSLayoutConstraint!// same here
    
    var copsInfoLabel: UILabelCustomization?
    var chatBubbleData: ChatBubbleData?
    var chatBubble: ChatBubble?
    var messageInfoData: MessageInfoData?
    var messageInfoLabel: UILabel?
    var messageMaxYPos: CGFloat = 10.0
    var imagePickerController = UIImagePickerController()
    var messageSourceImageView: UIImageView?
    var screenSize: CGRect?
    var recordingSession: AVAudioSession?
    var playAudioButton: UIButton?
    var audioController = MediaController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.mainScreen().bounds
        self.imagePickerController.delegate = self
        // notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);
        
        //Adding Connected Cops info
        self.messageInfoData = MessageInfoData(distance: 2, time: dateComponents(NSDate()), sourceType: .Sender, officerName: "Laxman")
        connectedOfficerView()
    
        // Adding an out going chat bubble
        self.chatBubbleData = ChatBubbleData(text: "", image: UIImage(named: "chatImage")!, sourceType: .Receiver, audioMessageView: nil)
        self.chatBubble = ChatBubble(data: chatBubbleData!, startY: self.messageMaxYPos + 10)
        self.messageMaxYPos = CGRectGetMaxY((chatBubble?.frame)!)
        self.mainScrollView.addSubview(self.messageSourceImage())
        self.mainScrollView.addSubview(chatBubble!)
        addMessageInfoLabel(messageMaxYPos + 10, parentView: self.mainScrollView)
        self.messageTextField.text = ""
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
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let changeInHeight = keyboardFrame.height * (showKeyboard ? 1 : -1)
        self.bottomConstraint.constant += changeInHeight
        self.view.layoutIfNeeded()
        
        switch showKeyboard {
        case true:
            if self.messageMaxYPos > ((self.screenSize?.height)! - keyboardFrame.height - 50) {
                self.mainScrollView.contentOffset.y = self.messageMaxYPos - keyboardFrame.height - 50
            }
        
        case false:
            self.mainScrollView.contentOffset.y = 0
        }
    }
    
    @IBAction func sendButtonAction(sender: UIButton) { // which button?
        switch MessageType(rawValue: (sender.titleLabel?.text)!)! as MessageType {
        case .Audio:
            if audioController.audioRecorder == nil {
                audioController.startRecording()
                self.audioMessageButton.setTitle("Recording", forState: .Normal)
            } else {
                audioController.finishRecording(success: true)
            }
            
        case .Text:
            guard let textMessage = self.messageTextField.text where textMessage != "" else {
                return
            }
            self.chatBubbleData = ChatBubbleData(text: self.messageTextField.text!, image: nil, sourceType: .Sender, audioMessageView: nil)
            self.chatBubble = ChatBubble(data: chatBubbleData!, startY: self.messageMaxYPos + 20)
            self.mainScrollView.addSubview(chatBubble!)
            
            self.messageMaxYPos = CGRectGetMaxY((chatBubble?.frame)!)
            self.mainScrollView.addSubview(self.messageSourceImage())
            self.messageTextField.text = ""
            self.messageInfoData = MessageInfoData(distance: 2, time: dateComponents(NSDate()), sourceType: .Sender, officerName: "")
            self.addMessageInfoLabel(messageMaxYPos + 10, parentView: self.mainScrollView)
        
        case .Recording:
            self.audioController.finishRecording(success: true)
            self.chatBubbleData = ChatBubbleData(text: "", image: nil, sourceType: .Sender, audioMessageView: nil)
            self.audioMessageButton.setTitle("Audio", forState: .Normal)
            let audioPlayerViewController = AudioPlayerViewController()
            self.messageMaxYPos = audioPlayerViewController.addAudioPlayerView(self.messageMaxYPos, sourceType: (self.chatBubbleData?.sourceType)!, parentView: self.mainScrollView, audioController: self.audioController)
            self.addChildViewController(audioPlayerViewController)
            audioPlayerViewController.didMoveToParentViewController(self)
            self.mainScrollView.addSubview(self.messageSourceImage())
            self.addMessageInfoLabel(messageMaxYPos + 10, parentView: self.mainScrollView)
            
            
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
    
    @IBAction func tapOutsideKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
        self.messageTextField.text = ""
    }
    
    func connectedOfficerView() {
        connectedOfficerImage()
        connectedOfficerInfo()
    }
    
    func connectedOfficerImage() {
        let copsImageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 50, height: 50))
        copsImageView.center.x = (self.screenSize?.width)! / 2
        copsImageView.image = UIImage(named: "receiverAvator")
        copsImageView.layer.cornerRadius = copsImageView.frame.width / 2
        copsImageView.layer.borderWidth = 5
        copsImageView.layer.borderColor = UIColor.whiteColor().CGColor
        copsImageView.clipsToBounds = true
        shadowInImage(copsImageView)
        self.messageMaxYPos = CGRectGetMaxY(copsImageView.frame)
        self.mainScrollView.addSubview(copsImageView)
    }
    
    func shadowInImage(imageView: UIImageView) {
        let path = UIBezierPath(arcCenter: imageView.center, radius: imageView.frame.width / 2 + 1, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        let layer = CAShapeLayer()
        layer.path = path.CGPath
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.zPosition = -1
        self.mainScrollView.layer.addSublayer(layer)
    }
    
    func connectedOfficerInfo() {
        self.copsInfoLabel = UILabelCustomization(frame: CGRect(x: 10, y: self.messageMaxYPos + 20, width: self.screenSize!.width * 0.50, height: 20))
        let officerName = (self.messageInfoData?.officerName)!
        self.copsInfoLabel!.backgroundColor = UIColor.greenColor()
        self.copsInfoLabel!.center.x = (self.screenSize?.width)! / 2
        self.copsInfoLabel!.layer.borderWidth = 1
        self.copsInfoLabel!.layer.cornerRadius = 10
        self.copsInfoLabel!.clipsToBounds = true
        self.copsInfoLabel!.layer.borderColor = UIColor.grayColor().CGColor
        self.copsInfoLabel!.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        self.copsInfoLabel!.numberOfLines = 0
        self.copsInfoLabel!.font = copsInfoLabel!.font.fontWithSize(11)
        self.copsInfoLabel!.text = "You're connected to Officer \(officerName)"
        self.copsInfoLabel?.sizeToFit()
        self.copsInfoLabel?.frame.size = CGSize(width: self.copsInfoLabel!.frame.width, height: self.copsInfoLabel!.frame.height + 20)
        self.mainScrollView.addSubview(copsInfoLabel!)
        self.messageMaxYPos = CGRectGetMaxY(copsInfoLabel!.frame)
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
        self.chatBubbleData = ChatBubbleData(text: "", image: imageMessage , sourceType: .Sender, audioMessageView: nil)
        self.chatBubble = ChatBubble(data: chatBubbleData!, startY: self.messageMaxYPos + 20)
        self.mainScrollView.addSubview(chatBubble!)
        self.messageMaxYPos = (self.chatBubble?.frame.maxY)!
        self.mainScrollView.addSubview(self.messageSourceImage())
        self.messageInfoData = MessageInfoData(distance: 10, time: dateComponents(NSDate()) , sourceType: .Sender, officerName: "")
        self.addMessageInfoLabel(messageMaxYPos + 10, parentView: self.mainScrollView)


    }
    
    func addMessageInfoLabel(startY: CGFloat, parentView: UIView) {
        self.messageInfoLabel = UILabel(frame: ChatBubble.framePrimary((self.chatBubbleData?.sourceType)!, startY: startY))
        self.messageInfoLabel?.font = self.messageInfoLabel?.font.fontWithSize(10)
        
        if self.chatBubbleData?.sourceType == .Receiver {
            self.messageInfoLabel?.text = (messageInfoData?.distance)! + " miles away" + "     " + (messageInfoData?.time)!
        } else {
            self.messageInfoLabel?.textAlignment = .Right
            self.messageInfoLabel?.text = (messageInfoData?.time)!
        }
        
        parentView.addSubview(messageInfoLabel!)
        self.messageMaxYPos = CGRectGetMaxY((messageInfoLabel?.frame)!)
        self.dummyBottomConstraint.constant = self.messageMaxYPos + 10
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
        self.mainScrollView.contentOffset = CGPoint(x: 0, y: self.messageMaxYPos)
    }
    
    func messageSourceImage() -> UIImageView {
        let xPosition: CGFloat =  self.chatBubbleData?.sourceType == .Sender ? self.screenSize!.width - 36 : 6
        let avatorHeight: CGFloat = 30
        let avatorWidth: CGFloat = 30
        self.messageSourceImageView = UIImageView(frame: CGRect(x: xPosition, y: self.messageMaxYPos - 15, width: avatorWidth, height: avatorHeight))
        self.messageSourceImageView?.layer.cornerRadius = (self.messageSourceImageView?.frame.size.width)! / 2
        self.messageSourceImageView?.layer.borderWidth = 2
        self.messageSourceImageView?.layer.borderColor = UIColor.whiteColor().CGColor
        self.messageSourceImageView?.clipsToBounds = true
        let actorImageName = self.chatBubbleData?.sourceType == .Sender ? "senderAvator" : "receiverAvator"
        self.messageSourceImageView?.image = UIImage(named: actorImageName)
        return self.messageSourceImageView!
    }
    
    override func viewWillDisappear(animated: Bool) {
        audioController.audioPlayer?.stop()
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
