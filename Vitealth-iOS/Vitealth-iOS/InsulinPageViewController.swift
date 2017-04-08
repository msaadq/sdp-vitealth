//
//  InsulinPageViewController.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 3/1/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit

class InsulinPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var excercisepicker: UIPickerView!
    
    @IBOutlet weak var calcInsulin: UIButton!
     var exercise: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.excercisepicker.dataSource = self;
        self.excercisepicker.delegate = self;

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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return exercise[row]
    }
    
    // Catpure the picker view selection
    private func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)-> String? {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print(exercise[row])
         return exercise[row]
    }

    
    @IBAction func CalcInsulinMethod(_ sender: Any) {
        let alert = UIAlertController(title: "Vitealth zPortal", message: "You should take 7 units of Insulin", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
