//
//  PatientInformationViewController.swift
//  Vitealth-iOS
//
//  Created by Saad Qureshi on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Firebase

class PatientInformationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var Typepicker: UIPickerView!
    @IBOutlet weak var Genderpicker: UIPickerView!
    @IBOutlet weak var BloodTypepicker: UIPickerView!
    @IBOutlet weak var displayname: UILabel!
    
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var height: UITextField!
    @IBOutlet weak var bdaypicker: UIDatePicker!
    @IBOutlet weak var h1bc: UITextField!
 
    @IBOutlet weak var ketonelevel: UITextField!
    @IBOutlet weak var drname: UITextField!
    @IBOutlet weak var dremail: UITextField!
    @IBOutlet weak var drphone: UITextField!
    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var license: UITextField!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    
    var bloodGroups: [String] = [String]()
    var gender: [String] = [String]()
    var types: [String] = [String]()
    var bloodSelected: Int=0  //selected by default
    var genderSelected: Int=0
    var typeSelected: Int=0
    
    
    @IBOutlet weak var savebutton: UIButton!
    
    @IBOutlet weak var cancelbutton: UIButton!
    
   // let ref = FIRDatabase.database().reference(withPath: "patient")
    
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
        
        var name="Display Name"
        let user = FIRAuth.auth()?.currentUser;
        if ((user ) != nil) {
            name=(user?.displayName)!
            displayname.text=name
        }
        self.Typepicker.dataSource=self
        self.Typepicker.delegate=self
        self.Genderpicker.dataSource=self
        self.Genderpicker.delegate=self
        self.BloodTypepicker.dataSource=self
        self.BloodTypepicker.delegate=self
        
        bloodGroups = ["A+","A-","AB+","AB-","B+","B-","O+","O-"]
        gender=["Male","Female"]
        types=["Type 1", "Type 2"]
        
        
       // scrollview = UIScrollView(frame: view.bounds)
    //scrollview.backgroundColor = UIColor.black
        scrollview.contentSize = CGSize(width:self.view.frame.width, height:self.view.frame.height+100)
       // scrollview.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == BloodTypepicker {
            return bloodGroups.count
        } else if pickerView == Genderpicker{
            return gender.count
        } else if pickerView == Typepicker{
            return types.count
        }
        return 0
    }
    
    // The data to return for the row and component (column) that's being passed in
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView == BloodTypepicker {
            bloodSelected=row
        } else if pickerView == Genderpicker{
            genderSelected=row
        }else if pickerView == Typepicker{
            typeSelected=row
        }
        
    }
    //font size
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.white
        
        if pickerView == BloodTypepicker {
            pickerLabel.text = bloodGroups[row]
        } else if pickerView == Genderpicker{
            pickerLabel.text = gender[row]
        }else if pickerView == Typepicker{
           pickerLabel.text = types[row]        }

        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
        pickerLabel.font = UIFont(name: "Helvetica Neue", size: 10) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
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

}
