import UIKit
import LocalAuthentication
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
    
    var victimName = "Sarah"
    var victimData: VictimData?
    var dummyTextField: UITextField?
    var passCodeDigitPos: Int = 0
    var isDeleteKeyPressed = false
    var inputPassCode: String?
    let myKeychainWrapper = KeychainWrapper()
    var context = LAContext()
    var isFirstLogin = true
    var keyboardHeight: CGFloat = 0
    var createPassword = false
    var passCode: String = ""
    var narrationeText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        victimData =  VictimData(name: victimName)
        createDummyTextField()
        showKeyBoard()
        self.narrationLabel.text = self.narrationeText

        self.dummyTextField?.delegate = self
        self.dummyTextField?.addTarget(self, action: #selector(textEditingChanged), forControlEvents: .EditingChanged)
        
        // Add comments
        self.isFirstLogin = NSUserDefaults.standardUserDefaults().boolForKey("isFirstLogin")
        
        //---
        //used for touch id verification
//        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:nil) {
//            loginUsingTouchID()
//        }
        if isFirstLogin {
            self.narrationeText = "Dear \((victimData?.victimName)!), Please enter your passcode to continue."
        } else {
             self.narrationeText = "Dear \((victimData?.victimName)!), Please verify your passcode."
        }
    }
    
    func createDummyTextField() {
        self.dummyTextField = UITextField(frame:CGRectMake(10,10,10,10))
        self.view.addSubview(dummyTextField!)
        self.dummyTextField!.keyboardType = .NumberPad
        self.dummyTextField!.hidden = true
    }
    
    private func showKeyBoard() {
        self.dummyTextField!.becomeFirstResponder()
    }
    
    func resizeDigitLabel(passCodeDigitLabel: UILabel) {
        if isDeleteKeyPressed {
            self.isDeleteKeyPressed = false
            passCodeDigitLabel.removeCircularView()
        } else {
            passCodeDigitLabel.frame.size.height = 24
            passCodeDigitLabel.createCircularView()
        }
        passCodeDigitLabel.center.y = (passCodeDigitLabel.superview?.frame.height)! / 2
    }
    
    func goToPreviousDigit() {
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
        self.passFirstDigitLabel.removeCircularView()
        self.passSecondDigitLabel.removeCircularView()
        self.passThirdDigitLabel.removeCircularView()
        self.passFourthDigitLabel.removeCircularView()
    }
    
    // transfer this to uitextfield delegate
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
    
//    / make a separate class for authenticataion
    func loginAction() {
        if self.isFirstLogin {
            if !self.createPassword {
                self.createPassword  = true
                self.passCodeDigitPos = 0
                resetAllLabelFrames()
                self.passCode = (self.dummyTextField?.text)!
                self.dummyTextField?.text = ""
                self.narrationLabel.text = self.narrationeText
            } else {
                self.createPassword  = false
                if self.passCode == self.dummyTextField?.text {
                    myKeychainWrapper.mySetObject(self.inputPassCode, forKey: kSecValueData)
                    myKeychainWrapper.writeToKeychain()
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstLogin")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    print("first time login sucessful")
                }
            }

        } else {
            print(inputPassCode)
            if inputPassCode == myKeychainWrapper.myObjectForKey(kSecValueData) as? String {
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
            goToPreviousDigit()
            self.passCodeDigitPos -= 1
        } else {
            if self.passCodeDigitPos < 4 {
                self.passCodeDigitPos += 1
                
                switch PassCodeDigitPos(rawValue: self.passCodeDigitPos)! as PassCodeDigitPos {
                case .First:
                    resizeDigitLabel(self.passFirstDigitLabel)
                case .Second:
                    resizeDigitLabel(self.passSecondDigitLabel)
                case .Third:
                    resizeDigitLabel(self.passThirdDigitLabel)
                case .Fourth:
                    resizeDigitLabel(self.passFourthDigitLabel)
                }
            } else {
                return false
            }
        }
        return true
    }
    
}
