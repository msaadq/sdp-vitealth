//
//  TabViewController.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 5/13/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Firebase

class TabViewController: UITabBarController {

    let ref = FIRDatabase.database().reference()
    var patient = Patient()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("main tab ")
        LoadLabels()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func LoadLabels()
    {
        
        
        
        
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
                
                
                self.patient.isNew=(userpatient?["isnewUser"] as? Bool)!
                self.patient.name=(userpatient?["name"] as? String)!
                self.patient.weight=(userpatient?["weight"] as? Int)!
                self.patient.height=(userpatient?["height"] as? Int)!
                self.patient.ketone=(userpatient?["ketone"] as? Int)!
                self.patient.h1bc=(userpatient?["h1bc"] as? Int)!
                self.patient.sugarTarget=(userpatient?["sugarTarget"] as? Int)!
                self.patient.basal=(userpatient?["basal"] as? String)!
                self.patient.bolus=(userpatient?["bolus"] as? String)!
                self.patient.drname=(userpatient?["drname"] as? String)!
                self.patient.drphone=(userpatient?["drphone"] as? Int)!
                self.patient.dremail=(userpatient?["dremail"] as? String)!
                self.patient.drdesig=(userpatient?["drdesig"] as? String)!
                self.patient.drlicense=(userpatient?["drlicense"] as? String)!
                self.patient.gender=(userpatient?["gender"] as? String)!
                self.patient.type=(userpatient?["type"] as? String)!
                self.patient.BloodType=(userpatient?["BloodType"] as? String)!
                self.patient.isNew=(userpatient?["isNew"] as? Bool)!
                self.patient.initialInsulin=(userpatient?["initialInsulin"] as? Int)!
                self.patient.lastseen=(userpatient?["lastseen"] as? Int)!
                self.patient.timeStamp=(userpatient?["timeStamp"] as? String)!
                self.patient.isnewUser=(userpatient?["isnewUser"] as? Bool)!

                
                
            
                            
                        })
        }
    }

}
