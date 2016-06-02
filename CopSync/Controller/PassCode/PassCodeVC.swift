import UIKit
import AudioToolbox

enum PassCodeDigitPos: Int {
    case First = 1
    case Second
    case Third
    case Fourth
}

class PassCodeVC: UIViewController {
    
    @IBOutlet private var narrationLabel: UILabel!
    @IBOutlet var passFirstDigitLabel: UILabel!
    @IBOutlet var passFourthDigitLabel: UILabel!
    @IBOutlet var passThirdDigitLabel: UILabel!
    @IBOutlet var passSecondDigitLabel: UILabel!
    @IBOutlet var passCodeContainerView: UIView!
    @IBOutlet var dummyTextField: UITextField!
    @IBOutlet var passCodeMsgLabel: UILabel!
    @IBOutlet var passCodeOptionButton: UIButton!
    
    var victimName = "Sarah"
    var victimData: VictimData?
    var passCodeDigitPos: Int = 0 //specifies the current passcode digit count
    var isDeleteKeyPressed = false
    var inputPassCode: String? //passcode entered for verification
    var isFirstLogin = true //specifies if it is first login of user or not
    var keyboardHeight: CGFloat = 0
    var createPassword = false //used to determine if the input shall be used to create password
    var passCode: String = "" //String used for verification of passcode at first launch
    var authentication = Authentication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        victimData =  VictimData(name: victimName)
        
        showKeyBoard()
        
        self.dummyTextField?.delegate = self
        self.dummyTextField?.addTarget(self, action: #selector(textEditingChanged), forControlEvents: .EditingChanged)
        
        // identifies if user have logged in for first time
        self.isFirstLogin = NSUserDefaults.standardUserDefaults().boolForKey("isFirstLogin")
        self.narrationLabel.text = "Dear \((victimData?.victimName)!), Please enter your passcode to continue."
    }
    
    private func showKeyBoard() {
        self.dummyTextField!.keyboardType = .NumberPad
        self.dummyTextField!.becomeFirstResponder()
    }
    
    func resizeDigitLabel(passCodeDigitLabel: UILabel) {
        if isDeleteKeyPressed {
            self.isDeleteKeyPressed = false
            passCodeDigitLabel.removeCircularView(3)
        } else {
            passCodeDigitLabel.createCircularView(24)
        }
        passCodeDigitLabel.center.y = (passCodeDigitLabel.superview?.frame.height)! / 2
    }
    
    func changeDigitPosition() {
        switch PassCodeDigitPos(rawValue: self.passCodeDigitPos)! {
        case .First:
            resizeDigitLabel(self.passFirstDigitLabel)
        case .Second:
            resizeDigitLabel(self.passSecondDigitLabel)
        case .Third:
            resizeDigitLabel(self.passThirdDigitLabel)
        case .Fourth:
            resizeDigitLabel(self.passFourthDigitLabel)
        }
    }

    func resetAllLabelFrames() {
        self.passFirstDigitLabel.removeCircularView(3)
        self.passSecondDigitLabel.removeCircularView(3)
        self.passThirdDigitLabel.removeCircularView(3)
        self.passFourthDigitLabel.removeCircularView(3)
    }
    
    func textEditingChanged() {
        if self.passCodeDigitPos == 0 {
            self.dummyTextField?.text = ""
        }
        self.inputPassCode = self.dummyTextField?.text
        if self.passCodeDigitPos == 4 {
            print(self.dummyTextField?.text)
            loginAction()
        }
    }
    
    func loginAction() {
        if self.isFirstLogin {
            if !self.createPassword {
                self.createPassword  = true
                self.passCodeDigitPos = 0
                resetAllLabelFrames()
                self.passCode = (self.dummyTextField?.text)!
                self.dummyTextField?.text = ""
                self.narrationLabel.text = "Dear \((victimData?.victimName)!), Please verify your passcode."
            } else {
                if self.passCode == self.dummyTextField?.text {
                    self.createPassword  = false
                    self.authentication.saveToKeyChain(self.passCode)
                    self.passCodeOptionButton.hidden = true
                    print("first time login sucessfully")
                } else {
                    self.createPassword  = true
                    self.passCodeMsgLabel.hidden = false
                    self.passCodeMsgLabel.text = "Passcode donot match. Try again"
                    self.passCodeOptionButton.hidden = true
                    self.passCodeDigitPos = 0
                    self.dummyTextField?.text = ""
                    resetAllLabelFrames()
                }
            }

        } else {
            if authentication.validatePassCode(self.inputPassCode!) {
                print("login sucessful")
            } else {
                let systemSoundID: SystemSoundID = 1016
                let triggerTime = (Int64(NSEC_PER_SEC) * Int64(1))
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    AudioServicesPlayAlertSound(systemSoundID)
                    self.resetAllLabelFrames()
                    self.performShakeAnimation(self.passCodeContainerView)
                    
                })
            }
        }
    }
    
    func performShakeAnimation(codeContainerView: UIView) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
                self.passCodeDigitPos = 0
                self.dummyTextField?.text = ""
            })
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(codeContainerView.center.x - 10, codeContainerView.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(codeContainerView.center.x + 10, codeContainerView.center.y))
        codeContainerView.layer.addAnimation(animation, forKey: "position")
        CATransaction.commit()
    }

}

extension PassCodeVC: UITextFieldDelegate {

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (string == "") {
            self.isDeleteKeyPressed = true
            changeDigitPosition()
            self.passCodeDigitPos -= 1
        } else {
            if self.passCodeDigitPos < 4 {
                self.passCodeDigitPos += 1
                changeDigitPosition()
            } else {
                return false
            }
        }
        return true
    }
    
    
    
}
