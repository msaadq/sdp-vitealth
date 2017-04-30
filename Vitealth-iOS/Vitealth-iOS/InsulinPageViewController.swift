//
//  InsulinPageViewController.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 3/1/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class InsulinPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var exercisepicker: UIPickerView!
    
    @IBOutlet weak var InsulinButton: UIButton!
    
    var exercise: [String] = [String]()
    var MealCarbs:Int=0
    var targetBGL:Int=100
    var nowBGL:Int=0
    var excSelected: Int=0  //no exercise selected by default
    var RuleVar:Int = 1700
    
    var tField: UITextField!
    
    let ref = FIRDatabase.database().reference()
    let doseref = FIRDatabase.database().reference(withPath: "dose")
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Here")
        print(MealCarbs)
        print(nowBGL)
        self.exercisepicker.dataSource=self
        self.exercisepicker.delegate=self
        // Do any additional setup after loading the view.
        exercise = ["Not exercising","Long duration,Moderate Intensity","Moderate Duration, High Intensity","Moderate Duration, Moderate Intensity","Short Duration,Low Intensity"]
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
        return exercise.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0 {
            
            excSelected = row
            
        }
        
    }
    
    
    //font size
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.white
        pickerLabel.text = exercise[row]
        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
        pickerLabel.font = UIFont(name: "Helvetica Neue", size: 15) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    
    
    
    
    @IBAction func ButtonPressInsulin(_ sender: Any) {
        var insulin:Int=0
        var yesterday_insulin:Int=0
        var bolustype:String = "Not known"
        var FirstTimeUser:Bool=true
        var lastchecked:Int=0
        
        
        let int_nowtime=Int(NSDate().timeIntervalSince1970)
        let nowtime=String(describing:int_nowtime )
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        //use the locale settings of the device by default
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        dateFormatter.locale = NSLocale.current
        let dayDate = dateFormatter.string(from: currentDate as Date)
        print(dayDate)
        
        
        
        
        let user = FIRAuth.auth()?.currentUser;
        
        if ((user) != nil) {
            print("User is signed in.")
            
            
            //get time
            let userID = user?.uid
            
            //get his bolus insulin
            ref.child("patient").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("oh snap")
                    return }
                let userpatient = snapshot.value as? NSDictionary
                bolustype = (userpatient?["bolus"] as? String)!
                print(bolustype)
                //Apply BD Rule Value for ISF
                if bolustype=="Regular"
                {self.RuleVar=1500 }
                else
                {self.RuleVar=1700}
                //is user logged in the first time
                FirstTimeUser=(userpatient?["isnewUser"] as? Bool)!
                print(FirstTimeUser)
                
                
                
                if FirstTimeUser {
                    //if user is using the portal for the first time, access the values from his information
                    yesterday_insulin=(userpatient?["initialInsulin"] as? Int)!
                    insulin=self.CalcInsulin(sumofunits: yesterday_insulin)
                    self.ref.child("patient").child(userID!).updateChildValues(["isnewUser": false])
                    self.ref.child("patient").child(userID!).updateChildValues(["lastseen": int_nowtime])
                    print("value set false")
                    let alert = UIAlertController(title: "Vitealth zPortal", message: "You should take " + "\(insulin)"+" units of Insulin", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic here")
                        let insulindose = Dose(insulinQuant: insulin,mealCarbs:self.MealCarbs,insulinType:bolustype,glucose:self.nowBGL,user: user!.email!,timeStamp:nowtime)
                        
                        print("Object created")
                        print(insulindose.user)
                        print((user?.uid)!)
                        let UserDoseRef = self.doseref.child(userID!).child(dayDate).child(nowtime)
                        UserDoseRef.setValue(insulindose.toAnyObject())
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                        self.AdjustInsulinDose(mealcarbs:self.MealCarbs,bolus:bolustype,BGL:self.nowBGL, email:user!.email!,time:nowtime,day:dayDate,uid:userID!)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else{
                    //86400 seconds in one day
                    //if user is not using the portal for the first time, access yesterdays values
                    //get value for lastseen
                    lastchecked=(userpatient?["lastseen"] as? Int)!
                    print(lastchecked)
                    //update last seen
                    self.ref.child("patient").child(userID!).updateChildValues(["lastseen": int_nowtime])
                    let offline_time=int_nowtime-lastchecked
                    print(offline_time)
                    var dormantDays:Int=1 //by default get the day before
                    if offline_time > 86400  //if user was last seen more than a day ago
                    {
                        
                        if offline_time > 86400 && offline_time < 172800 {
                            dormantDays = 2
                        } else if offline_time > 172800 && offline_time < 259200  {
                            dormantDays=3
                        }
                    }
                    
                    let intfetchDate=NSDate(timeIntervalSince1970:TimeInterval(int_nowtime-(dormantDays*86400)))
                    let fechDate=dateFormatter.string(from: intfetchDate as Date)
                    print("calc isf from ",fechDate)
                    self.ref.child("dose").child(userID!).child(fechDate).observeSingleEvent(of: .value, with: { (snapshot) in
                        if !snapshot.exists() {
                            print("oh snap")
                            let alert = UIAlertController(title: "Vitealth zPortal", message: "Oh snap, something went wrong", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return }
                        
                        
                        //if exists
                        print("get all daily doses")
                        
                        var dailydoses = [Dose]()
                        for item in snapshot.children {
                            let dailydose = Dose(snapshot: item as! FIRDataSnapshot)
                            dailydoses.append(dailydose)
                            yesterday_insulin=yesterday_insulin+dailydose.insulinQuant
                        }
                        
                        
                        
                        print("yesterday insulin",yesterday_insulin)
                        
                        insulin=self.CalcInsulin(sumofunits:  yesterday_insulin) //for now
                        print("insulin",insulin)
                        let alert = UIAlertController(title: "Vitealth zPortal", message: "You should take " + "\(insulin)"+" units of Insulin", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                            print("Handle Ok logic here")
                            let insulindose = Dose(insulinQuant: insulin,mealCarbs:self.MealCarbs,insulinType:bolustype,glucose:self.nowBGL,user: user!.email!,timeStamp:nowtime)
                            
                            print("Object created")
                            print(insulindose.user)
                            print((user?.uid)!)
                            let UserDoseRef = self.doseref.child(userID!).child(dayDate).child(nowtime)
                            UserDoseRef.setValue(insulindose.toAnyObject())
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                            print("Handle Cancel Logic here")
                            self.AdjustInsulinDose(mealcarbs:self.MealCarbs,bolus:bolustype,BGL:self.nowBGL, email:user!.email!,time:nowtime,day:dayDate,uid:userID!)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    })
                    
                }
                
               
                
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
        } else {
            print("No user is signed in.")
        }
        
        
    }
    
    
    
    func CalcCarbInsulinRatio(units: Int) -> Int {
        let PrevCarbIntake=500
        return PrevCarbIntake/units
    }
    
    func CalcInsulinSensitivity(units: Int) -> Int {
        print(RuleVar)
        return RuleVar/units
    }
    
    func CalcExerciseComponent() -> Int {
        let exerciseComponent:Int
        switch nowBGL {
        case 70..<100:
            if excSelected==0 {
                exerciseComponent = 0
            } else if excSelected==1 {
                exerciseComponent = ExerciseParameters.LowBloodSugar.LongDurModInt
            } else if excSelected==2{
                exerciseComponent = ExerciseParameters.LowBloodSugar.ModDurHighInt
            } else if excSelected==3{
                exerciseComponent = ExerciseParameters.LowBloodSugar.ModDurModInt
            } else {
                exerciseComponent = ExerciseParameters.LowBloodSugar.ShortDurLowInt
            }
            
        case 100..<120:
            if excSelected==0 {
                exerciseComponent = 0
            } else if excSelected==1 {
                exerciseComponent = ExerciseParameters.MedBloodSugar.LongDurModInt
            } else if excSelected==2{
                exerciseComponent = ExerciseParameters.MedBloodSugar.ModDurHighInt
            } else if excSelected==3{
                exerciseComponent = ExerciseParameters.MedBloodSugar.ModDurModInt
            } else {
                exerciseComponent = ExerciseParameters.MedBloodSugar.ShortDurLowInt
            }
        case 121..<180:
            if excSelected==0 {
                exerciseComponent = 0
            } else if excSelected==1 {
                exerciseComponent = ExerciseParameters.MedHighBloodSugar.LongDurModInt
            } else if excSelected==2{
                exerciseComponent = ExerciseParameters.MedHighBloodSugar.ModDurHighInt
            } else if excSelected==3{
                exerciseComponent = ExerciseParameters.MedHighBloodSugar.ModDurModInt
            } else {
                exerciseComponent = ExerciseParameters.MedHighBloodSugar.ShortDurLowInt
            }
            
        case 180..<250:
            if excSelected==0 {
                exerciseComponent = 0
            } else if excSelected==1 {
                exerciseComponent = ExerciseParameters.HighBloodSugar.LongDurModInt
            } else if excSelected==2{
                exerciseComponent = ExerciseParameters.HighBloodSugar.ModDurHighInt
            } else if excSelected==3{
                exerciseComponent = ExerciseParameters.HighBloodSugar.ModDurModInt
            } else {
                exerciseComponent = ExerciseParameters.HighBloodSugar.ShortDurLowInt
            }
            
        default:
            exerciseComponent=0
        }
        return exerciseComponent
    }
    
    
    func CalcInsulin(sumofunits: Int) -> Int {
        //get yesterdays sum of units
        let ISF=CalcInsulinSensitivity(units: sumofunits)
        print("isf is",ISF)
        let CarbInsRatio=CalcCarbInsulinRatio(units: sumofunits)
        print("CarbInsRatio is",CarbInsRatio)
        let InsulinUnits=(MealCarbs/CalcCarbInsulinRatio(units: sumofunits))+((nowBGL-targetBGL)/CalcInsulinSensitivity(units: sumofunits))-CalcExerciseComponent()
        return InsulinUnits
    }
    func configurationTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = "Enter the dose appropriate for you"
        tField = textField
    }
    
   
    func AdjustInsulinDose(mealcarbs:Int,bolus:String,BGL:Int, email:String,time:String,day:String,uid:String){
        
        print("Method Called")
        let alert = UIAlertController(title: "Readjust your insulin dose", message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
            print("Done !!")
            let insulin=Int(self.tField.text!)
            let insulindose = Dose(insulinQuant: insulin!,mealCarbs:mealcarbs,insulinType:bolus,glucose:BGL,user: email,timeStamp:time)
            
            print("Object created")
            
            let UserDoseRef = self.doseref.child(uid).child(day).child(time)
            UserDoseRef.setValue(insulindose.toAnyObject())

            print("Item : \(String(describing: self.tField.text))")
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        
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
