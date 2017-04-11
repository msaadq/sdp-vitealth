//
//  GlucometerViewController.swift
//  Vitealth-iOS
//
//  Created by Saad Qureshi on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit

class GlucometerViewController: UIViewController {

    @IBOutlet weak var pebbleStatus: UILabel!
    @IBOutlet weak var readingProgress: UIProgressView!
    @IBOutlet weak var bglValue: UILabel!
    
    
    var MealCarbs:Int=0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bglValue.text = "BGL = " + "(Pebble Not Connected)"
        pebbleStatus.text = "Not Connected"
        readingProgress.progress = 0.0
        print(MealCarbs)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectToPebble(_ sender: Any) {
        pebbleStatus.text = "Connecting..."
        pebbleStatus.textColor = UIColor.yellow
        readingProgress.progress = 0.5
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Create a variable that you want to send
        if(segue.identifier == "GotoInsulinPage") {
            
            let yourNextViewController = (segue.destination as! InsulinPageViewController)
            yourNextViewController.MealCarbs = MealCarbs
        }
    }

}
