//
//  SettingsViewController.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 5/12/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import Material


class SettingsViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    var patient=Patient()
    var basalinsulins:[String]=[String]()
    var bolusinsulins:[String]=[String]()
    var bolusSelected:Int=0
    var basalSelected:Int=0
    let storageRef = FIRStorage.storage().reference()
    let user = FIRAuth.auth()?.currentUser;
    let ref = FIRDatabase.database().reference()
    
    
    
    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var height: UITextField!
    
    @IBOutlet weak var weight: UITextField!
    
    @IBOutlet weak var h1bc: UITextField!

    @IBOutlet weak var ketone: UITextField!
    
    @IBOutlet weak var glutarget: UITextField!
    
    @IBOutlet weak var phyname: UITextField!
    
    @IBOutlet weak var phydesig: UITextField!
    @IBOutlet weak var phyphone: UITextField!
    
    @IBOutlet weak var phyemail: UITextField!
    
    @IBOutlet weak var license: UITextField!
    
    @IBOutlet weak var basalpicker: UIPickerView!
    
    @IBOutlet weak var boluspicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadpicture()
        //picture
        picture.layer.borderWidth = 1
        picture.layer.masksToBounds = false
        picture.layer.cornerRadius = picture.frame.height/2
        picture.clipsToBounds = true
        
        basalinsulins=["Lantus", "Utralente"]
        bolusinsulins=["Humalog", "Regular","Novolog","Apidra"]
        
        let tbvc = self.tabBarController  as! TabViewController
        patient = tbvc.patient
        Name.text=patient.name
        
        height.text=String(patient.height)
        weight.text=String(patient.weight)
        h1bc.text=String(patient.h1bc)
        ketone.text=String(patient.ketone)
        glutarget.text=String(patient.sugarTarget)
        phyname.text=patient.drname
        phyphone.text=String(patient.drphone)
        phyemail.text=patient.dremail
        phydesig.text=patient.drdesig
        license.text=patient.drlicense
        
        
        self.boluspicker.dataSource=self
        self.boluspicker.delegate=self
        self.basalpicker.dataSource=self
        self.basalpicker.delegate=self
        
        //set picker to user values
        if patient.bolus == "Humalog" {
            bolusSelected=0
        } else if patient.bolus == "Regular"{
            bolusSelected=1

        } else if patient.bolus == "Novolog"{
            bolusSelected=2

        } else if patient.bolus == "Apidra"{
            bolusSelected=3
        }
        if patient.basal == "Lantus" {
            basalSelected=0
        } else if patient.basal == "Utralente"{
            basalSelected=1
        }
        
        basalpicker.selectRow(basalSelected, inComponent:0, animated:true)
        boluspicker.selectRow(bolusSelected, inComponent:0, animated:true)
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Hiding keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)

        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadpicture()
    {
        let filePath = "\(user!.uid)/\("userPhoto")"
        let dbRef = storageRef.child(filePath)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        dbRef.data(withMaxSize: 1 * 1024 * 1024, completion: { data, error in
            if error != nil {
                print("Uh-oh, an error occurred!")
            } else {
                // Data for image  is returned
                let image = UIImage(data: data!)
                self.picture.image=image
            }
        })
        
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         if pickerView == boluspicker{
            return bolusinsulins.count
        } else if pickerView == basalpicker{
            return basalinsulins.count
        }
        
        
        
        return 0
    }
    
    // The data to return for the row and component (column) that's being passed in
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
         if pickerView == boluspicker{
            bolusSelected=row
        }else if pickerView == basalpicker{
            basalSelected=row
        }
        
    }
    //font size
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        
         if pickerView == basalpicker{
            pickerLabel.text = basalinsulins[row]
        }else if pickerView == boluspicker{
            pickerLabel.text = bolusinsulins[row]
        }
        
        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
        pickerLabel.font = UIFont(name: "Helvetica Neue", size: 15) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    @IBAction func SaveButtonPressed(_ sender: Any) {
        let thisPatient = Patient(name:patient.name!,weight: Int(weight.text!)!,height:Int(height.text!)!,ketone:Int(ketone.text!)!,h1bc:Int(h1bc.text!)!,age:patient.age,gender:patient.gender!,type:patient.type!,BloodType:patient.BloodType!,basal:basalinsulins[basalSelected],bolus:bolusinsulins[bolusSelected],isNew:patient.isNew,initialInsulin:patient.initialInsulin,dremail:phyemail.text!,useremail: user!.email!,timeStamp:patient.timeStamp!,lastseen:patient.lastseen,isnewUser:patient.isnewUser,sugarTarget:Int(glutarget.text!)!,drname:phyname.text!,drphone:Int(phyphone.text!)!,drdesig:phydesig.text!, drlicense:license.text!)
        let PatientRef = self.ref.child((user?.uid)!)
        PatientRef.setValue(thisPatient.toAnyObject())
        let alert = UIAlertController(title: "Vitealth zPortal", message: "Your information has been updated", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print("saved")
    }
    
    
    @IBAction func logOut(_ sender: Any) {
        do{
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "signOut", sender: self)
        }catch{
            print("Error while signing out!")
        }
    }
    
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
