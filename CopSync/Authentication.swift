import Foundation
import LocalAuthentication

class Authentication {
    
    var myKeychainWrapper = KeychainWrapper()
    let context = LAContext()
    
    func saveToKeyChain(inputCode: String) {
        self.myKeychainWrapper.mySetObject(inputCode, forKey: kSecValueData)
        self.myKeychainWrapper.writeToKeychain()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstLogin")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func validatePassCode(inputCode: String) -> Bool {
        let codeFromKeyChain = self.myKeychainWrapper.myObjectForKey(kSecValueData) as! String
        if inputCode == codeFromKeyChain {
            return true
        } else {
            return false
        }
    }
    
}