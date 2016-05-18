import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var audioMessageButton: UIButton!
    
    enum MessageAction: String {
        case SendMessage = "Send"
        case RecordAudioMessage = "Audio"
    }
    
    var chatBubbleDataMine: ChatBubbleData?
    var chatBubbleMine: ChatBubble?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        mainScrollView.scrollEnabled = true;
        // Adding an out going chat bubble
        self.chatBubbleDataMine = ChatBubbleData(text: "Hey there!!! How are you?fjajgalkjgalkjglajglkajgajkglajklajglkagjaka  fjaljkflkaj a fjalfjaljkaflkalfj  fjalfjka", image: UIImage(named: "chatImage")!, date: NSDate(), sourceType: .Mine, distance: 10)
        self.chatBubbleMine = ChatBubble(data: chatBubbleDataMine!, startY: 50)
        self.mainScrollView.addSubview(chatBubbleMine!)
        
        // Adding an incoming chat bubble
        var chatBubbleDataOpponent = ChatBubbleData(text: "Fine bro!!! check this out", image: UIImage(named: "chatImage")!, date: NSDate(), sourceType: .Others, distance: 20)
        var chatBubbleOpponent = ChatBubble(data: chatBubbleDataOpponent, startY: CGRectGetMaxY(chatBubbleMine!.frame) + 10)
        self.mainScrollView.addSubview(chatBubbleOpponent)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        adjustHeight(true, notification: sender)
    }
    
    // Adjust bottom constraint of the view for typing message according to keyboard status.
    func adjustHeight(showKeyboard: Bool, notification: NSNotification) {
        var userInfo = notification.userInfo
        var keyboardFrame = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue?)!.CGRectValue()
        let animationDuration = userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let changeInHeight = keyboardFrame.height * (showKeyboard ? 1 : -1)
        self.bottomConstraint.constant = changeInHeight
        UIView.animateWithDuration(animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        self.mainScrollView.contentOffset.y = 150
    
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.audioMessageButton.setTitle("Send", forState: .Normal)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    @IBAction func sendMessageButton(sender: UIButton) {
        print(sender.titleLabel?.text)
        switch sender.titleLabel?.text {
        case MessageAction.RecordAudioMessage.rawValue?:
            print("record audio")
            
        case MessageAction.SendMessage.rawValue?:
            print("Send message")
        default:
            return
        }
        self.chatBubbleDataMine = ChatBubbleData(text: self.messageTextField.text!, image: nil, date: NSDate(), sourceType: .Mine, distance: 10)
        self.chatBubbleMine = ChatBubble(data: chatBubbleDataMine!, startY: 10)
        self.mainScrollView.addSubview(chatBubbleMine!)
        
    }

}
