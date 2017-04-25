//
//  SignUpViewController.swift
//  Vitealth-iOS
//
//  Created by Saad Qureshi on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
class SignUpViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Hiding keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
    }


    @IBAction func signUp(_ sender: Any) {
        
        if email.text == "" || password.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        else if firstName.text == "" || lastName.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your name", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            FIRAuth.auth()!.createUser(withEmail: email.text!,
                                       password: password.text!) { user, error in
                                        if error == nil {
                                            print("success")
                                            let alertController = UIAlertController(title: "Vitealth zPortal", message:
                                                "Successful Registration!", preferredStyle: UIAlertControllerStyle.alert)
                                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                                            
                                            self.present(alertController, animated: true, completion: nil)

                                            //sign in
                                           FIRAuth.auth()!.signIn(withEmail: self.email.text!,password: self.password.text!)
                                           //set username
                                            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                                            let UserName=self.firstName.text! + " "+self.lastName.text!
                                            print(UserName)
                                            changeRequest?.displayName = UserName
                                            changeRequest?.commitChanges() { (error) in
                                                if error == nil {
                                                    print("User name added")
                                                    self.performSegue(withIdentifier: "signUp", sender: nil)
                                                } else {
                                                     print("User name not added")
                                                     self.performSegue(withIdentifier: "backToLogin", sender: nil)
                                                }
                                            }
                                            //listener to check
                                            //FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                                               // if user != nil {
                                                //    self.performSegue(withIdentifier: "signUp", sender: nil)
                                               // } else {
                                                    // No User is signed in. Show user the login screen
                                               //     self.performSegue(withIdentifier: "backToLogin", sender: nil)
                                              //  }
                                           // }
                                            
                                        }
                                        else {
                                            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                                            
                                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                            alertController.addAction(defaultAction)
                                            
                                            self.present(alertController, animated: true, completion: nil)
                                        }
            }
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
