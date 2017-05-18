//
//  DashboardViewController.swift
//  Vitealth-iOS
//
//  Created by Saad Qureshi on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Material
import Firebase

class DashboardViewController: UIViewController {
    var patient=Patient()

    @IBOutlet weak var mainDisplay: UITextView!
    
    
    @IBOutlet weak var max: UILabel!
    
    @IBOutlet weak var min: UILabel!
    @IBOutlet weak var avg: UILabel!
    
    @IBOutlet weak var redDrop: UIImageView!
    
    @IBOutlet weak var yellowDrop: UIImageView!
    
    @IBOutlet weak var greenDrop: UIImageView!
    
    
    @IBOutlet weak var units1: UILabel!
    
    @IBOutlet weak var units2: UILabel!
    
    @IBOutlet weak var units3: UILabel!
    
    @IBOutlet weak var units4: UILabel!
    
    @IBOutlet weak var basalButton: RaisedButton!
    
    static var yestdailydoses = [Dose]()
    static var todaydailydoses = [Dose]()
    static var yestDailyDosesBolus = [Dose]()
    static var todayDailyDosesBolus = [Dose]()

    
    
    let ref = FIRDatabase.database().reference()
    let doseref = FIRDatabase.database().reference(withPath: "dose")
    var tField: UITextField!
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadLabels()
            }
    
    
    override func viewDidLoad() {
        print("view load entered")
        super.viewDidLoad()
        //activityIndicator.hidesWhenStopped = true;
       // activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
       // activityIndicator.center = view.center;
       // LoadLabels()
        
        redDrop.layer.borderWidth = 1
        redDrop.layer.masksToBounds = false
        redDrop.layer.cornerRadius = redDrop.frame.height/2
        redDrop.clipsToBounds = true
        redDrop.layer.borderColor = UIColor.red.cgColor
        yellowDrop.layer.borderWidth = 1
        yellowDrop.layer.masksToBounds = false
        yellowDrop.layer.cornerRadius = yellowDrop.frame.height/2
        yellowDrop.clipsToBounds = true
        yellowDrop.layer.borderColor = UIColor.cyan.cgColor
        greenDrop.layer.borderWidth = 1
        greenDrop.layer.masksToBounds = false
        greenDrop.layer.cornerRadius = greenDrop.frame.height/2
        greenDrop.clipsToBounds = true
        greenDrop.layer.borderColor = UIColor.green.cgColor
 

       

        
        
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ActionCompleted()
    {
        let alertController1 = UIAlertController(title: "Vitealth zPortal", message:" Basal Insulin Administered" , preferredStyle: .alert)
        
        let defaultAction1 = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController1.addAction(defaultAction1)
        
        self.present(alertController1, animated: true, completion: nil)
    }
    
    
    func CalcBasalInsulin(weight:Int) -> Int
    {
        var basal:Int
        basal = (weight*55 )/100
        print (basal)
        return basal
    }
    func configurationTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = "Enter the units of insulin"
        tField = textField
    }
    @IBAction func BasalButtonPressed(_ sender: Any) {
        var basaltype:String = "Not known"
        var patient_weight:Int = 0
        var basalQuant:Int = 0
        
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
        
        
        let user = FIRAuth.auth()?.currentUser;
        
        if ((user) != nil) {
            print("User is signed in.")
            //get id
            let userID = user?.uid
            //get his basal insulin and weight
            ref.child("patient").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("oh snap")
                    return }
                let userpatient = snapshot.value as? NSDictionary
                basaltype = (userpatient?["basal"] as? String)!
                patient_weight = (userpatient?["weight"] as? Int)!
                print(basaltype)
                print(patient_weight)
                basalQuant=self.CalcBasalInsulin(weight: patient_weight)
                let alert = UIAlertController(title: "Vitealth zPortal", message: "Enter the basal insulin dose you are about to take. We recommed " + "\(basalQuant)"+" units.", preferredStyle: .alert)
                
                alert.addTextField(configurationHandler: self.configurationTextField)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
                    print("Done !!")
                    let basalInsulin=Int(self.tField.text!)
                    //create dose
                    let basaldose = Dose(insulinQuant: basalInsulin!,mealCarbs:0,insulinType:basaltype,glucose:0,user:(user?.email)!,timeStamp:nowtime,timeofday:hour,basal:true)
                    
                    print("Object created")
                    
                    let UserDoseRef = self.doseref.child(userID!).child(dayDate).child(nowtime)
                    UserDoseRef.setValue(basaldose.toAnyObject())
                    
                    print("Item : \(String(describing: self.tField.text))")
                    
                }))
                self.present(alert, animated: true, completion: {
                    self.ActionCompleted()
                    
                })

                
                
            })

        }

        
    }
    
    func LoadLabels()
    {
        var FirstTimeUser:Bool=true
        var lastchecked:Int=0
        var BGLs=[Int]()
        
        let int_nowtime=Int(NSDate().timeIntervalSince1970)
      
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        //use the locale settings of the device by default
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        dateFormatter.locale = NSLocale.current
        let dayDate = dateFormatter.string(from: currentDate as Date)
        print(dayDate)
        
        
        // Do any additional setup after loading the view.
        let user = FIRAuth.auth()?.currentUser;
        
        if ((user) != nil) {
            print("User is signed in.")
            let userID = user?.uid
            
            //get his bolus insulin
            ref.child("patient").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("oh snap")
                    self.mainDisplay.text=" Couldn't fetch details."
                    return }
                let userpatient = snapshot.value as? NSDictionary
                
                FirstTimeUser=(userpatient?["isnewUser"] as? Bool)!

             
                
                
                
                //is user logged in the first time
                print(FirstTimeUser)
                if FirstTimeUser {
                    self.mainDisplay.text="Welcome to Vitealth zPortal,a fitbit for Diabetes. Proceed to Glucometer if you want to check your Sugar Level"
                    
                }
                else{
                    lastchecked=(userpatient?["lastseen"] as? Int)!
                    let offline_time=int_nowtime-lastchecked
                    print("User been away for ",offline_time)
                    var activeDays:Int=1 //by default get the day before
                    if offline_time > 86400  //if user was last seen more than a day ago
                    {
                        
                        if offline_time > 86400 && offline_time < 172800 {
                            activeDays = 2
                            
                            
                        } else if offline_time > 172800   {
                            activeDays = 0
                            self.mainDisplay.text="We haven't seen you for a while"
                        }
                        
                        
                    }
                    if activeDays != 0
                    {
                        var breakfast_units:Int=0
                        var lunch_units:Int = 0
                        var dinner_units:Int = 0
                        var nonmeal_units:Int = 0
                        var averageBGL:Int = -1
                        let intfetchDate=NSDate(timeIntervalSince1970:TimeInterval(int_nowtime-(activeDays*86400)))  //replace 3 with active days
                       
                        let fechDate=dateFormatter.string(from: intfetchDate as Date)
                         print("display from ",fechDate)
                        self.ref.child("dose").child(userID!).child(dayDate).observeSingleEvent(of: .value, with: { (snapshot) in
                            if !snapshot.exists() {
                                print("oh snap")
                            }
                            print("get all daily doses from today")
                            
                            DashboardViewController.todaydailydoses.removeAll()
                            
                            for item in snapshot.children {
                                let dailydose = Dose(snapshot: item as! FIRDataSnapshot)
                                DashboardViewController.todaydailydoses.append(dailydose)
                                
                                if !dailydose.basal {
                                    DashboardViewController.todayDailyDosesBolus.append(dailydose)
                                }
                                
                                if(dailydose.mealCarbs == 0)
                                {nonmeal_units=nonmeal_units+dailydose.insulinQuant}
                                else{
                                    if(dailydose.timeofday > 5 && dailydose.timeofday < 12)
                                    {breakfast_units=breakfast_units+dailydose.insulinQuant}
                                    else if(dailydose.timeofday > 12 && dailydose.timeofday < 17)
                                    {lunch_units=breakfast_units+dailydose.insulinQuant}
                                    else
                                    {dinner_units=dinner_units+dailydose.insulinQuant}
                                    
                                }
                                
                                
                                
                            }
                            print("set insulins")
                            //set insulin units
                            self.units1.text=String(breakfast_units) + " units"
                            self.units2.text=String(lunch_units) + " units"
                            self.units3.text=String(dinner_units) + " units"
                            self.units4.text=String(nonmeal_units) + " units"
                            
                            
                            
                        })
                        self.ref.child("dose").child(userID!).child(fechDate).observeSingleEvent(of: .value, with: { (snapshot) in
                            if !snapshot.exists() {
                                print("oh snap")
                                
                            }
                            print("get all daily doses from yesterday")
                            
                            
                            DashboardViewController.yestdailydoses.removeAll()
                            
                            var sumofBGLs:Int=0
                            for item in snapshot.children {
                                let dailydose = Dose(snapshot: item as! FIRDataSnapshot)
                                if !dailydose.basal
                                {
                                    DashboardViewController.yestdailydoses.append(dailydose)
                                    DashboardViewController.yestDailyDosesBolus.append(dailydose)
                                    BGLs.append(dailydose.glucose)
                                    sumofBGLs=sumofBGLs+dailydose.glucose
                                }
                                
                                
                            }
                            print("Set BGL labels")
                            
                            var maxBGLstr = "   mg/dl"
                            var minBGLstr = "   mg/dl"
                            var avgBGLstr = "   mg/dl"
                            if let maxBGL = BGLs.max() {
                                maxBGLstr = "\(maxBGL)"
                                self.max.text="   "+maxBGLstr+" mg/dl"
                            }
                            if let minBGL = BGLs.min() {
                                minBGLstr = "\(minBGL)"
                                self.min.text="   "+minBGLstr+" mg/dl"
                            }
                            
                            let average =  Int(sumofBGLs/BGLs.count)  //( BGLs as NSArray).value(forKeyPath: "@avg.self") as? Int
                            avgBGLstr = "\(average)"
                            averageBGL=average
                            self.avg.text="   "+avgBGLstr+" mg/dl"
                            

                           
                            print(averageBGL)
                            if averageBGL == -1{
                                print("no avg")
                                self.mainDisplay.text=" Couldn't fetch details."
                            }
                            else if averageBGL<=90 {
                                
                            self.mainDisplay.text=" Your average blood glucose is low. Consider increasing carb intake or decreasing insulin."
                            }
                            else if averageBGL>=130 {
                              
                            self.mainDisplay.text=" Your average blood glucose is high. Consider decreasing carb intake or increasing insulin."
                            }
                            else if averageBGL>90 && averageBGL<130{
                             self.mainDisplay.text=" Your average blood glucose is in range. You are on the road to good health."
                            }
                            
                            
                            
                            
                            
                        })
                        

                        
                    }
                }
                
                
            })
            
        }

    }
    
    // MARK: - Navigation
    
   

 
}
