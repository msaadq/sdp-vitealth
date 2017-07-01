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
    var nowBGL:Int=0
    var excSelected: Int=0  //no exercise selected by default
    var targetBGL:Int=100
    var RuleVar:Int = 1700
    var CarbInsRatio: Float = 0.0
    
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
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = exercise[row]
        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
        pickerLabel.font = UIFont(name: "Helvetica Neue", size: 15) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    
    
    
    
    @IBAction func ButtonPressInsulin(_ sender: Any) {
        var insulin:Int=0
        var yesterday_insulin:Int=0
        var yesterday_totalcarb:Int=0
        var bolustype:String = "Not known"
        var basaltype:String = "Not known"
        var FirstTimeUser:Bool=true
        var lastchecked:Int=0
        var recordInsulin:Int=0
        var residue:Float=0
        
        
        
        //Get Time Block insluding epoch, time of day, and string
        let int_nowtime=Int(NSDate().timeIntervalSince1970)
        let nowtime=String(describing:int_nowtime )
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        //use the locale settings of the device by default
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        dateFormatter.locale = NSLocale.current
        let dayDate = dateFormatter.string(from: currentDate as Date)
        print(dayDate)
        let hour = Calendar.current.component(.hour, from: Date())
        print(hour)
        
        
        //Get user
        
        let user = FIRAuth.auth()?.currentUser;
        //If user got, proceed
        if ((user) != nil) {
            print("User is signed in.")
            
            
            //get id
            let userID = user?.uid
            
            //get his patient details-> bolus,basal,sugarTarget,inial Insulin used, when last dose taken, if he's new
            ref.child("patient").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("oh snap")
                    return }
                
                //insert else?
                let userpatient = snapshot.value as? NSDictionary
                bolustype = (userpatient?["bolus"] as? String)!
                basaltype = (userpatient?["basal"] as? String)!
                self.targetBGL = (userpatient?["sugarTarget"] as? Int)!
                
                lastchecked=(userpatient?["lastseen"] as? Int)!//get value for lastseen
                recordInsulin=(userpatient?["initialInsulin"] as? Int)!  //in case user does not  have a yesterday record and in case user is first time using
                FirstTimeUser=(userpatient?["isnewUser"] as? Bool)!
                print("User details fetched such as ",bolustype,basaltype)
                
                
                //Apply BD Rule Value for ISF depending on his bolus insulin
                if bolustype=="Regular"
                {self.RuleVar=1500 }
                else
                {self.RuleVar=1700}
                
                
                
                
                print("/Is user logged in the first time ",FirstTimeUser)
                
                
                
                if FirstTimeUser {
                    //if user is using the portal for the first time, access the values from his information
                    
                    //Apply 500 Rule
                    insulin=self.CalcInsulin(sumofunits: yesterday_insulin,sumofcarbs:500,residualeffect:0)
                    
                    print("value set false")
                    let alert = UIAlertController(title: "Vitealth zPortal", message: "You should take " + "\(insulin)"+" units of Insulin", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic here")
                        let insulindose = Dose(insulinQuant: insulin,mealCarbs:self.MealCarbs,insulinType:bolustype,glucose:self.nowBGL,user: user!.email!,timeStamp:nowtime,timeofday:hour, basal:false)
                        
                        print("Dose Object created")
                        
                        let UserDoseRef = self.doseref.child(userID!).child(dayDate).child(nowtime)
                        UserDoseRef.setValue(insulindose.toAnyObject())
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                        self.AdjustInsulinDose(mealcarbs:self.MealCarbs,bolus:bolustype,BGL:self.nowBGL, email:user!.email!,time:nowtime,day:dayDate,uid:userID!,hourday: hour)
                    }))
                    
                    self.present(alert, animated: true, completion: {
                        print("completion block")
                        print("Dose Object saved")
                        //update last seen and new tag
                        self.ref.child("patient").child(userID!).updateChildValues(["isnewUser": false])
                        self.ref.child("patient").child(userID!).updateChildValues(["lastseen": int_nowtime])
                    })
                    
                }
                else{
                    //86400 seconds in one day
                    //if user is not using the portal for the first time, access yesterdays values
                    
                    print("last checked",lastchecked)
                    print("nowtime",nowtime)
                    //update last seen
                    
                    let offline_time=int_nowtime-lastchecked
                    print(offline_time)
                    var activeDays:Int=1 //by default get the day before
                    if offline_time > 86400  //if user was last seen more than a day ago
                    {
                        
                        if offline_time > 86400 && offline_time < 172800 {
                            activeDays = 2
                            
                        } else if offline_time > 172800   {
                            activeDays = 0
                        }
                    }
                    
                    print("active days",activeDays)
                    //if user hasnt used app for a long time
                    if activeDays==0
                    {
                        let Enteralert = UIAlertController(title: "Vitealth zPortal", message: "You haven't used the app in a while.We can't tell.", preferredStyle: .alert)
                        
                        Enteralert.addTextField(configurationHandler: self.configurationTextField)
                        Enteralert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
                        Enteralert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
                            print("Done !!")
                            //use 500 Rule and ask user for his stats
                            yesterday_insulin=Int(self.tField.text!)!
                            yesterday_totalcarb=500
                            print("Insulin used yesterday : \(String(describing: self.tField.text))")
                            insulin=self.CalcInsulin(sumofunits:  yesterday_insulin, sumofcarbs:yesterday_totalcarb,residualeffect: 0) //for now
                            print("insulin",insulin)
                            
                            self.DisplayInsulin(insulin_q: insulin,meal_carbs:self.MealCarbs,_bolus:bolustype,_BGL:self.nowBGL, _email:user!.email!,_time:nowtime,_day:dayDate,_uid:userID!,hourofday:hour)
                            
                            
                        }))
                        self.present(Enteralert, animated: true, completion: {
                            print("completion block")
                            self.ref.child("patient").child(userID!).updateChildValues(["lastseen": int_nowtime])
                            self.ref.child("patient").child(userID!).updateChildValues(["initialInsulin": yesterday_insulin])
                        })
                        
                        
                    }
                        
                        
                    else
                    {
                        let intfetchDate=NSDate(timeIntervalSince1970:TimeInterval(int_nowtime-(activeDays*86400)))
                        let fechDate=dateFormatter.string(from: intfetchDate as Date)
                        print("calc isf from ",fechDate)
                        self.ref.child("dose").child(userID!).child(fechDate).observeSingleEvent(of: .value, with: { (snapshot) in
                            if !snapshot.exists() {
                                print("The record for the day not there")
                                print(recordInsulin)
                                insulin=self.CalcInsulin(sumofunits:  recordInsulin, sumofcarbs:500,residualeffect: 0) //for now
                                print(insulin)
                                self.DisplayInsulin(insulin_q: insulin,meal_carbs:self.MealCarbs,_bolus:bolustype,_BGL:self.nowBGL, _email:user!.email!,_time:nowtime,_day:dayDate,_uid:userID!,hourofday:hour)
                                self.ref.child("patient").child(userID!).updateChildValues(["lastseen": int_nowtime])
                            }
                                
                                
                                //if exists
                            else{
                                print("get all daily doses")
                                //get all doses from yesterday
                                var dailydoses = [Dose]()
                                
                                for item in snapshot.children {
                                    let dailydose = Dose(snapshot: item as! FIRDataSnapshot)
                                    dailydoses.append(dailydose)
                                    
                                    yesterday_insulin=yesterday_insulin+dailydose.insulinQuant  //sum of insulin used yesterday
                                    yesterday_totalcarb=yesterday_totalcarb+dailydose.mealCarbs //sum of carbs eaten yesterday
                                    self.ref.child("patient").child(userID!).updateChildValues(["lastseen": int_nowtime]) 
                                
                                    
                                }
                                
                                print("yesterday insulin1",yesterday_insulin)
                                if yesterday_totalcarb == 0 //if user didnot take carbs the whole day yesterday, use 500 Rule
                                {yesterday_totalcarb=500}
                                
                                
                                //to check for residual insulin
                                //get doses taken today
                                self.ref.child("dose").child(userID!).child(dayDate).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if !snapshot.exists() {  //no record of any insulin doses from today
                                        residue=0.0
                                    }
                                    else{
                                        //if there is insulin taken today, are there basal doses?
                                        var todaybasaldoses = [Dose]()
                                        for item in snapshot.children {
                                            let todaydose = Dose(snapshot: item as! FIRDataSnapshot)
                                            if todaydose.basal  //separate basal doses taken today
                                            {
                                                todaybasaldoses.append(todaydose)
                                                
                                            }
                                            
                                        }
                                        if !todaybasaldoses.isEmpty  //if  basal dose taken today
                                        {
                                            
                                            let lastbasaldose=todaybasaldoses.last  //last basal dose
                                            let elapsedminutes:Float=(Float(int_nowtime)-Float((lastbasaldose?.timeStamp)!)!)/60
                                            print("User took basal minutes  ago",elapsedminutes)
                                            residue = self.CalcResidueInsulin(time:elapsedminutes,quantity:(lastbasaldose?.insulinQuant)!,type:(lastbasaldose?.insulinType)!)
                                        }
                                        else   //no basal dose taken yet
                                        {
                                            print("no basal doses taken yet")
                                            residue=0.0
                                        }
                                        
                                        
                                    }
                                    
                                    print("Residual effect", residue)
                                    
                                    insulin=self.CalcInsulin(sumofunits:  yesterday_insulin, sumofcarbs:yesterday_totalcarb,residualeffect:residue) //for now
                                    print("insulin",insulin)
                                    
                                    self.DisplayInsulin(insulin_q: insulin,meal_carbs:self.MealCarbs,_bolus:bolustype,_BGL:self.nowBGL, _email:user!.email!,_time:nowtime,_day:dayDate,_uid:userID!,hourofday:hour)
                                    self.ref.child("patient").child(userID!).updateChildValues(["lastseen": int_nowtime])
                                    
                                })
                            }
                        })
                    }
                    
                    
                    
                    
                    
                    
                    
                }
                
                
                
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
        } else {
            print("No user is signed in.")
        }
        
        
    }
    
    
    
    func CalcCarbInsulinRatio(units: Int,PrevCarbIntake:Int) -> Float {
        let _units = Float(units)
        let _PrevCarbIntake = Float(PrevCarbIntake)
        
        print("sumofunits",_units)
        print("PrevCarbIntake",_PrevCarbIntake)
        return (_PrevCarbIntake/_units)
    }
    
    func CalcInsulinSensitivity(units: Int) -> Float {
        print(RuleVar)
        let _RuleVar=Float(RuleVar)
        let _units=Float(units)
        return (_RuleVar/_units)
    }
    func CalcResidualComponent(typeInsulin:String) -> Int {
        let activity_duration:Int
        print(typeInsulin)
        switch typeInsulin {
        case "Lantus":
            
            
            let activity_lower=Insulin.LongAction.Lantus.onsetmin+Insulin.LongAction.Lantus.activationtime
            let activity_higher=Insulin.LongAction.Lantus.onsetmax+Insulin.LongAction.Lantus.activationtime
            activity_duration=activity_higher-activity_lower
            
        case "Utralente":
        
            let activity_lower=Insulin.LongAction.Ultralente.onsetmin+Insulin.LongAction.Ultralente.activationtimemin
            let activity_higher=Insulin.LongAction.Ultralente.onsetmax+Insulin.LongAction.Ultralente.activationtimemax
            activity_duration=activity_higher-activity_lower
            print(activity_duration)
        default:
            activity_duration = -1
            print("default")
            
        }
        return activity_duration
    }
    func CalcResidueInsulin(time:Float, quantity:Int,type:String)-> Float{
        let peakactivity = CalcResidualComponent(typeInsulin: type)
        print("peak activity",peakactivity)
        let int_minutes=Int(time)
        print("int minutes", int_minutes)
        var residue:Float
        if int_minutes > peakactivity {
            print("Exceeds peak activity")
            residue=0.0
        }
        else{
            residue = (1.0-(Float(int_minutes/peakactivity)))*Float(quantity)
            if Int(residue)<0
            {residue=0.0
            }
        }
        return residue
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
    
    
    func CalcInsulin(sumofunits: Int, sumofcarbs:Int, residualeffect:Float) -> Int {
        //get yesterdays sum of units
        let ISF=CalcInsulinSensitivity(units: sumofunits)
        print("isf is",ISF)
        
        CarbInsRatio=CalcCarbInsulinRatio(units: sumofunits,PrevCarbIntake:sumofcarbs)
        print("CarbInsRatio is",CarbInsRatio)
        print("residual effect",residualeffect)
        let MealComponent:Float=Float(MealCarbs)/CarbInsRatio
        print("Meal Component",MealComponent)
        let target_difference=nowBGL-targetBGL
        let ISFComponent:Float=Float(target_difference)/ISF
        print("ISF Component",ISFComponent)
        let ExerciseComponent = Float(CalcExerciseComponent())
        print("Exercise component",ExerciseComponent )
        
        let InsulinUnits:Float = MealComponent + ISFComponent + ExerciseComponent - residualeffect
        return Int(InsulinUnits)
    }
    func readjustTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = "Enter the dose appropriate for you"
        tField = textField
    }
    func configurationTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = "Enter the sum of insulin you used yesterday"
        tField = textField
    }
    
    
    func AdjustInsulinDose(mealcarbs:Int,bolus:String,BGL:Int, email:String,time:String,day:String,uid:String,hourday:Int){
        
        print("Method Called")
        let alert = UIAlertController(title: "Vitealth zPortal", message: "Readjust your insulin dose", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: readjustTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
            print("Done !!")
            let insulin=Int(self.tField.text!)
            let insulindose = Dose(insulinQuant: insulin!,mealCarbs:mealcarbs,insulinType:bolus,glucose:BGL,user: email,timeStamp:time,timeofday:hourday,basal:false)
            
            print("Object created")
            
            let UserDoseRef = self.doseref.child(uid).child(day).child(time)
            UserDoseRef.setValue(insulindose.toAnyObject())
            
            print("Item : \(String(describing: self.tField.text))")
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        
    }
    
    func DisplayInsulin(insulin_q:Int,meal_carbs:Int,_bolus:String,_BGL:Int, _email:String,_time:String,_day:String,_uid:String,hourofday:Int)
    {
        
        if true {//insulin_q >= 0 {
            print(" insulin calc",insulin_q)
            
            let alert = UIAlertController(title: "Vitealth zPortal", message: "You should take " + "\(3)"+" units of Insulin", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                let insulindose = Dose(insulinQuant: insulin_q,mealCarbs:meal_carbs,insulinType:_bolus,glucose:_BGL,user: _email,timeStamp:_time,timeofday:hourofday,basal:false)
                
                print("Object created")
                
                let UserDoseRef = self.doseref.child(_uid).child(_day).child(_time)
                UserDoseRef.setValue(insulindose.toAnyObject())
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
                self.AdjustInsulinDose(mealcarbs:meal_carbs,bolus:_bolus,BGL:_BGL, email:_email,time:_time,day:_day,uid:_uid,hourday:hourofday)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Vitealth zPortal", message: "You should take " + "\(insulin_q * Int(CarbInsRatio))"+" units of Carbohydrates", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
                let insulindose = Dose(insulinQuant: insulin_q,mealCarbs:meal_carbs,insulinType:_bolus,glucose:_BGL,user: _email,timeStamp:_time,timeofday:hourofday,basal:false)
                
                print("Object created")
                
                let UserDoseRef = self.doseref.child(_uid).child(_day).child(_time)
                UserDoseRef.setValue(insulindose.toAnyObject())
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
                self.AdjustInsulinDose(mealcarbs:meal_carbs,bolus:_bolus,BGL:_BGL, email:_email,time:_time,day:_day,uid:_uid,hourday:hourofday)
            }))

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
