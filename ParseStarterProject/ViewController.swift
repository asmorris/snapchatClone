/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser()?.username != nil {
            self.performSegueWithIdentifier("showUserTable", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                
                var user = PFUser()
                user.username = self.usernameTextField.text!
                user.password = self.passwordTextField.text!
                print("Here we are again!")
                user.signUpInBackgroundWithBlock({ (success, error) in
                    if let error = error {
                        let errorString = error.userInfo["error"] as! String
                        self.errorMessageLabel.text = "Error: " + errorString
                    } else {
                        print("Signed up")
                    }
                })
            } else {
                print("Logged in")

            }
            self.performSegueWithIdentifier("showUserTable", sender: self)
        }

    }
    
    
    //MARK: - Text fields
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        
    }
    
}
