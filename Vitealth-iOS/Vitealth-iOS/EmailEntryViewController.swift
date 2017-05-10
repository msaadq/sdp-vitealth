//
//  EmailEntryViewController.swift
//  Vitealth-iOS
//
//  Created by Saad Qureshi on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import FirebaseAuth
import Material
class EmailEntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var pwdTextField: UITextField!
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    @IBOutlet weak var loginbutton: UIButton!
    var UserInSystem = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginbutton.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(EmailEntryViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EmailEntryViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Hiding keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EmailEntryViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        
        //Monitor User Auth
       /* FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                self.UserInSystem=true
            }
        }*/
    }
    
    
    // MARK: Check email validity
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    @IBAction func moveToNext(_ sender: Any) {
        if let email = emailTextField.text as String! {
            
            if(isValidEmail(testStr: email)) {
                self.emailTextField.resignFirstResponder()
                if let pwd = pwdTextField.text as String!
                {
                    FIRAuth.auth()!.signIn(withEmail: email,
                                           password: pwd){ (user, error) in
                                            if error == nil {
                                                
                                                //Print into the console if successfully logged in
                                                print("You have successfully logged in")
                                                self.performSegue(withIdentifier: "oldUser", sender: nil)
}
                                            else{
                                                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                                                
                                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                alertController.addAction(defaultAction)
                                                
                                                self.present(alertController, animated: true, completion: nil)

                                            }
                                            
                    }
                    
                }
                
                
                
            }
            else {
                let alertController = UIAlertController(title: "Error", message: "Please enter your credentials", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
            }

        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: Keyboard
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height / 2
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
