//
//  PatientInformationViewController.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import Material

class PatientInformationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var Typepicker: UIPickerView!
    @IBOutlet weak var Genderpicker: UIPickerView!
    @IBOutlet weak var BloodTypepicker: UIPickerView!
    @IBOutlet weak var displayname: UILabel!
    
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var boluspicker: UIPickerView!
    @IBOutlet weak var basalpicker: UIPickerView!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var height: UITextField!
    @IBOutlet weak var h1bc: UITextField!
    @IBOutlet weak var sugartarget: TextField!
 
    @IBOutlet weak var age: TextField!
    @IBOutlet weak var ketonelevel: UITextField!
    @IBOutlet weak var drname: UITextField!
    @IBOutlet weak var dremail: UITextField!
    @IBOutlet weak var drphone: UITextField!
    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var license: UITextField!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var newSwitch: UISwitch!
    
    @IBOutlet weak var recommendationLabel: UILabel!
    
    @IBOutlet weak var diabetesStack: UIStackView!
    @IBOutlet weak var yestUnits: UITextField!
    
    var imagepicker=UIImagePickerController()
    
    var name="Display Name"
    var bloodGroups: [String] = [String]()
    var gender: [String] = [String]()
    var types: [String] = [String]()
    var basalinsulins:[String]=[String]()
    var bolusinsulins:[String]=[String]()
    var bloodSelected: Int=0  //selected by default
    var genderSelected: Int=0
    var typeSelected: Int=0
    var bolusSelected:Int=0
    var basalSelected:Int=0
    
    
    @IBOutlet weak var savebutton: UIButton!
    
    @IBOutlet weak var cancelbutton: UIButton!
    
    let ref = FIRDatabase.database().reference(withPath: "patient")
    let storageRef = FIRStorage.storage().reference()
    let user = FIRAuth.auth()?.currentUser;
    
    
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
        
        
        
        //enable profile picture
        imagepicker.delegate=self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        pictureView.isUserInteractionEnabled = true
        pictureView.addGestureRecognizer(tapGestureRecognizer)
        pictureView.layer.borderWidth = 1
        pictureView.layer.masksToBounds = false
        //pictureView.layer.borderColor = UIColor.black
        pictureView.layer.cornerRadius = pictureView.frame.height/2
        pictureView.clipsToBounds = true
        
        
        displayname.text=name
        
        self.Typepicker.dataSource=self
        self.Typepicker.delegate=self
        self.Genderpicker.dataSource=self
        self.Genderpicker.delegate=self
        self.BloodTypepicker.dataSource=self
        self.BloodTypepicker.delegate=self
        self.boluspicker.dataSource=self
        self.boluspicker.delegate=self
        self.basalpicker.dataSource=self
        self.basalpicker.delegate=self
        
        
        bloodGroups = ["A+","A-","AB+","AB-","B+","B-","O+","O-"]
        gender=["Male","Female"]
        types=["Type 1", "Type 2"]
        basalinsulins=["Lantus", "Utralente"]
        bolusinsulins=["Humalog", "Regular","Novolog","Apidra"]
        
       
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //if old diabetic , display more text fields

    @IBAction func SwitchTriggered(_ sender: Any) {
        if newSwitch.isOn {
            recommendationLabel.isHidden=false
            recommendationLabel.text=" Please consult your physician on a blood glucose target"
            print("on")
            
        } else {
            recommendationLabel.isHidden=true
            print("off")
        }
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
        } else if pickerView == boluspicker{
            return bolusinsulins.count
        } else if pickerView == basalpicker{
            return basalinsulins.count
        }


        
        return 0
    }
    
    
    @IBAction func SignOut(_ sender: Any) {
        do{
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "signOut", sender: self)
        }catch{
            print("Error while signing out!")
        }
        
    }
    
    // The data to return for the row and component (column) that's being passed in
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView == BloodTypepicker {
            bloodSelected=row
        } else if pickerView == Genderpicker{
            genderSelected=row
        }else if pickerView == Typepicker{
            typeSelected=row
        }else if pickerView == boluspicker{
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
        
        if pickerView == BloodTypepicker {
            pickerLabel.text = bloodGroups[row]
        } else if pickerView == Genderpicker{
            pickerLabel.text = gender[row]
        }else if pickerView == Typepicker{
           pickerLabel.text = types[row]
        }else if pickerView == basalpicker{
            pickerLabel.text = basalinsulins[row]
        }else if pickerView == boluspicker{
            pickerLabel.text = bolusinsulins[row]
        }

        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
        pickerLabel.font = UIFont(name: "Helvetica Neue", size: 15) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    
    @IBAction func SavebuttonPressed(_ sender: Any) {
       
        var isnewdiabetic:Bool
        
        
        
        if ((user) != nil) {
            print("User is signed in.")
        } else {
            print("No user is signed in.")
        }
        
        //get isNewdiabetic?
        if newSwitch.isOn
        {
            isnewdiabetic=true
            
            
            
        }
        else{
            isnewdiabetic=false
            
           
        }
        print("about to save")
        let thisPatient = Patient(name:name,weight: Int(weight.text!)!,height:Int(height.text!)!,ketone:Int(ketonelevel.text!)!,h1bc:Int(h1bc.text!)!,age:Int(age.text!)!,gender:gender[genderSelected],type:types[typeSelected],BloodType:bloodGroups[bloodSelected],basal:basalinsulins[basalSelected],bolus:bolusinsulins[bolusSelected],isNew:isnewdiabetic,initialInsulin:Int(yestUnits.text!)!,dremail:dremail.text!,useremail: user!.email!,timeStamp:String(describing: NSDate().timeIntervalSince1970),lastseen:0,isnewUser:true,sugarTarget:Int(sugartarget.text!)!,drname:drname.text!,drphone:Int(drphone.text!)!,drdesig:designation.text!, drlicense:license.text!)
        let PatientRef = self.ref.child((user?.uid)!)
        PatientRef.setValue(thisPatient.toAnyObject())
        let alert = UIAlertController(title: "Vitealth zPortal", message: "Your information has been stored", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print("saved")
        
        
        
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagepicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            imagepicker.allowsEditing = true
            self.present(imagepicker, animated: true, completion: nil)
            
            print("Presented images")
        }
    }
    
    
    

        
   
 

 
    
    

    //MARK: ImageButton
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        let alert = UIAlertController(title: "Vitealth zPortal", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        
        alert.addAction(UIAlertAction(title: "Open Photos", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Library Logic here")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                self.imagepicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                self.imagepicker.allowsEditing = true
                self.present(self.imagepicker, animated: true, completion: nil)
                
                print("Presented images")
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Open Camera", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Camera logic here")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                self.imagepicker.sourceType = UIImagePickerControllerSourceType.camera;
                self.imagepicker.allowsEditing = true
                self.present(self.imagepicker, animated: true, completion: nil)
                
                print("Presented images")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("here")
        if let imageselected = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pictureView.image=imageselected
            print("image success")
            var data = NSData()  //get data
            data = UIImageJPEGRepresentation(pictureView.image!, 0.8)! as NSData
            // set upload path
            let filePath = "\(user!.uid)/\("userPhoto")"
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            // When the image has successfully uploaded, we get it's download URL
            self.storageRef.child(filePath).put(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else{
                    //store downloadURL
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    print(downloadURL)
                    //store downloadURL at database
                    // Write the download URL to the Realtime Database
                   // let dbRef = database.reference().child("myFiles/myFile")
                   // dbRef.setValue(downloadURL)
                    //self.databaseRef.child("users").child(user!.uid).updateChildValues(["userPhoto": downloadURL])
                }
                
            }
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    // MARK: Keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
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
