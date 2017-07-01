//
//  GlucometerViewController.swift
//  Vitealth-iOS
//
//  Created by Saad Qureshi on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Firebase

class GlucometerViewController: UIViewController {

    @IBOutlet weak var pebbleStatus: UILabel!
    @IBOutlet weak var readingProgress: UIProgressView!
    @IBOutlet weak var bglValue: UILabel!
    
    var latest_bgl = 0
    var bgl_accessed = true
    
    static var ref: FIRDatabaseReference!
    
    var MealCarbs:Int=0
    var BGL:UInt32=0
    override func viewDidLoad() {
        super.viewDidLoad()
        GlucometerViewController.ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view.
        
        bglValue.text = "BGL = " + "(Pebble Not Connected)"
        pebbleStatus.text = "Not Connected"
        readingProgress.progress = 0.0
        print(MealCarbs)
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let distanceRef = GlucometerViewController.ref.child("demo")
        
        distanceRef.child("bgl_accessed").setValue(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectToPebble(_ sender: Any) {
        pebbleStatus.text = "Connecting..."
        pebbleStatus.textColor = UIColor.yellow
        readingProgress.progress = 0.5
        
        
        
        //for now generate random no.
        let randomBGL:UInt32 = arc4random_uniform(260)+50 // range is 50 to 310
        print(randomBGL)
        BGL=randomBGL
        
        let date = NSDate(timeIntervalSince1970: 1493101250)
        print(date)
            
        
        
        
        //wait
        sleep(5)
        pebbleStatus.text = "Connected"
        pebbleStatus.textColor = UIColor.green
        readingProgress.progress = 1
        self.bglValue.text = "BGL = calculating..."
        

        let refHandle = GlucometerViewController.ref.child("demo").observe(FIRDataEventType.value, with: { (snapshot) in
            
            if let demo = snapshot.value as? NSDictionary {
                
                self.bgl_accessed = demo["bgl_accessed"] as! Bool!
                self.latest_bgl = demo["latest_bgl"] as! Int!
                
                if !self.bgl_accessed {
                    self.bglValue.text = "BGL = \(String(self.latest_bgl)) mg/dl"
                } else {
                    self.bglValue.text = "BGL = calculating..."
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
            
        }

        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Create a variable that you want to send
        if(segue.identifier == "GotoInsulinPage") {
            
            let yourNextViewController = (segue.destination as! InsulinPageViewController)
            yourNextViewController.MealCarbs = MealCarbs
            yourNextViewController.nowBGL = Int(BGL)
        }
    }

}
