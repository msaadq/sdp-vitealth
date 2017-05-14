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

    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var max: UILabel!
    
    @IBOutlet weak var min: UILabel!
    @IBOutlet weak var avg: UILabel!
    
    
    @IBOutlet weak var units1: UILabel!
    
    @IBOutlet weak var units2: UILabel!
    
    @IBOutlet weak var units3: UILabel!
    
    @IBOutlet weak var units4: UILabel!
    
    @IBOutlet weak var basalButton: RaisedButton!
    
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
       

        
        
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    print("completion block")
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
                    return }
                let userpatient = snapshot.value as? NSDictionary
                
                FirstTimeUser=(userpatient?["isnewUser"] as? Bool)!

             
                
                
                
                //is user logged in the first time
                print(FirstTimeUser)
                if FirstTimeUser {
                    self.mainLabel.text="Welcome to Vitealth zPortal,a fitbit for Diabetes. Proceed to Glucometer if you want to check your Sugar Level"
                    
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
                            self.mainLabel.text="We haven't seen you for a while"
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
                        self.ref.child("dose").child(userID!).child(fechDate).observeSingleEvent(of: .value, with: { (snapshot) in
                            if !snapshot.exists() {
                                print("oh snap")
                            }
                            print("get all daily doses")
                            
                            var dailydoses = [Dose]()
                            for item in snapshot.children {
                                let dailydose = Dose(snapshot: item as! FIRDataSnapshot)
                                if !dailydose.basal
                                {
                                    dailydoses.append(dailydose)
                                    BGLs.append(dailydose.glucose)
                                    print(dailydose.glucose)
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
                                
                                
                            }
                            
                            print("Set BGL labels")
                            
                            var maxBGLstr = "max =__ mg/dl"
                            var minBGLstr = "min =__ mg/dl"
                            var avgBGLstr = "avg =__ mg/dl"
                            if let maxBGL = BGLs.max() {
                                maxBGLstr = "\(maxBGL)"
                                self.max.text="max ="+maxBGLstr+" mg/dl"
                            }
                            if let minBGL = BGLs.min() {
                                minBGLstr = "\(minBGL)"
                                self.min.text="min ="+minBGLstr+" mg/dl"
                            }
                            if let average: Int = ( BGLs as NSArray).value(forKeyPath: "@avg.self") as? Int
                            {
                                avgBGLstr = "\(average)"
                                averageBGL=average
                                 self.avg.text="avg ="+avgBGLstr+" mg/dl"
                            }

                           
                            
                            
                           
                            

                            if averageBGL == -1{
                                self.mainLabel.text=" Couldn't fetch details."
                            }
                            else if averageBGL<90 {
                            self.mainLabel.text=" Your average blood glucose is low. Consider increasing carb intake or decreasing insulin."
                            }
                            else if averageBGL>130 {
                            self.mainLabel.text=" Your average blood glucose is high. Consider decreasing carb intake or increasing insulin."
                            }
                            else if averageBGL>90 && averageBGL<130{
                             self.mainLabel.text=" Your average blood glucose is in range. You are on the road to good health."
                            }
                            
                            
                            
                            //set insulin units
                            self.units1.text=String(breakfast_units) + " units"
                            self.units2.text=String(lunch_units) + " units"
                            self.units3.text=String(dinner_units) + " units"
                            self.units4.text=String(nonmeal_units) + " units"
                            
                            
                            
                        })
                    }
                }
                
                
            })
            
        }

    }
    
    // MARK: - Navigation
    
   

 
}
