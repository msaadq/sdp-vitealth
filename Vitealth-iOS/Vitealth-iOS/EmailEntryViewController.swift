//
//  EmailEntryViewController.swift
//  Vitealth-iOS
//
//  Created by Saad Qureshi on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit

class EmailEntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    var emailInSystem = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(EmailEntryViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EmailEntryViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Hiding keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EmailEntryViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
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
                
                if self.emailInSystem == true {
                    performSegue(withIdentifier: "oldUser", sender: nil)
                } else {
                    performSegue(withIdentifier: "newUser", sender: nil)
                }
                
            }
        } else {
            print("Invalid Email")
        }
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height / 2
            }
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
