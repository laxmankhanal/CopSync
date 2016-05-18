import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var audioMessageButton: UIButton!
    
    enum MessageAction: String {
        case SendMessage = "Send"
        case RecordAudioMessage = "Audio"
    }
    
    enum ImageSourceType: String {
        case Camera = "Camera"
        case PhotoLibrary = "PhotoLibrary"
    }
    
    var imageSourceType: ImageSourceType?
    var chatBubbleDataMine: ChatBubbleData?
    var chatBubbleMine: ChatBubble?
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePickerController.delegate = self
        self.messageTextField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);
        mainScrollView.scrollEnabled = true;
//        // Adding an out going chat bubble
//        self.chatBubbleDataMine = ChatBubbleData(text: "Hey there!!! How are you?fjajgalkjgalkjglajglkajgajkglajklajglkagjaka  fjaljkflkaj a fjalfjaljkaflkalfj  fjalfjka", image: UIImage(named: "chatImage")!, date: NSDate(), sourceType: .Mine, distance: 10)
//        self.chatBubbleMine = ChatBubble(data: chatBubbleDataMine!, startY: 50)
//        self.mainScrollView.addSubview(chatBubbleMine!)
//        
//        // Adding an incoming chat bubble
//        var chatBubbleDataOpponent = ChatBubbleData(text: "Fine bro!!! check this out", image: UIImage(named: "chatImage")!, date: NSDate(), sourceType: .Others, distance: 20)
//        var chatBubbleOpponent = ChatBubble(data: chatBubbleDataOpponent, startY: CGRectGetMaxY(chatBubbleMine!.frame) + 10)
//        self.mainScrollView.addSubview(chatBubbleOpponent)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        adjustHeight(true, notification: sender)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        adjustHeight(false, notification: sender)
    }
    
    // Adjust bottom constraint of the view for typing message according to keyboard status.
    func adjustHeight(showKeyboard: Bool, notification: NSNotification) {
        var userInfo = notification.userInfo
        var keyboardFrame = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue?)!.CGRectValue()
        print("FRAME: \(keyboardFrame)")
        let animationDuration = userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let changeInHeight = keyboardFrame.height * (showKeyboard ? 1 : -1)
        self.bottomConstraint.constant += changeInHeight
        self.view.layoutIfNeeded()
        switch showKeyboard {
        case true:
            self.mainScrollView.contentOffset.y = 150
        
        case false:
            self.mainScrollView.contentOffset.y = 0
        default:
            return
        }
        
        print(changeInHeight)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.audioMessageButton.setTitle("Send", forState: .Normal)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    @IBAction func sendButtonAction(sender: UIButton) {
        print(sender.titleLabel?.text)
        switch sender.titleLabel?.text {
        case MessageAction.RecordAudioMessage.rawValue?:
            print("record audio")
            
        case MessageAction.SendMessage.rawValue?:
            self.view.endEditing(true)
            self.chatBubbleDataMine = ChatBubbleData(text: self.messageTextField.text!, image: nil, date: NSDate(), sourceType: .Mine, distance: 10)
            self.chatBubbleMine = ChatBubble(data: chatBubbleDataMine!, startY: 10)
            self.mainScrollView.addSubview(chatBubbleMine!)
            
        default:
            return
        }
    }
    
    @IBAction func takeImageButtonAction(sender: UIButton) {
        let alert = UIAlertController(title: "Select image source", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: ImageSourceType.Camera.rawValue, style: UIAlertActionStyle.Default, handler: {
            action in
                self.pickImageFrom(ImageSourceType.Camera)
        })
        
        let galleryAction = UIAlertAction(title: ImageSourceType.PhotoLibrary.rawValue, style: UIAlertActionStyle.Default, handler: {
            action in
                self.pickImageFrom(ImageSourceType.PhotoLibrary)
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

    func pickImageFrom(imageSource: ImageSourceType) {
        self.imagePickerController.allowsEditing = false
        if (imageSource == .Camera && UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            self.imagePickerController.sourceType = .Camera
        } else {
            self.imagePickerController.sourceType = .PhotoLibrary
        }
        self.presentViewController(self.imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendImageMessage(pickedImage);
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendImageMessage(imageMessage: UIImage) {
        self.chatBubbleDataMine = ChatBubbleData(text: "Hey there!!! How are you?fjajgalkjgalkjglajglkajgajkglajklajglkagjaka  fjaljkflkaj a fjalfjaljkaflkalfj  fjalfjka", image: imageMessage , date: NSDate(), sourceType: .Mine, distance: 10)
        self.chatBubbleMine = ChatBubble(data: chatBubbleDataMine!, startY: 0)
        self.mainScrollView.addSubview(chatBubbleMine!)

    }
    

}
