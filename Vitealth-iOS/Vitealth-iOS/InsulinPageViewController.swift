//
//  InsulinPageViewController.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 3/1/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit

class InsulinPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    
    @IBOutlet weak var exercisepicker: UIPickerView!
  
    @IBOutlet weak var InsulinButton: UIButton!
 
    var exercise: [String] = [String]()
    var MealCarbs:Int=0
    var targetBGL:Int=100
    var nowBGL:Int=190
    var excSelected: Int=0  //no exercise selected by default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Here")
        print(MealCarbs)
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
    /*
    // Catpure the picker view selection
    private func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if pickerView.tag == 0 {
            
           excSelected = row
            
        }
    }
 */

    

   
    @IBAction func ButtonPressInsulin(_ sender: Any) {
        let insulin:Int
        insulin=CalcInsulin()
        let alert = UIAlertController(title: "Vitealth zPortal", message: "You should take " + "\(insulin)"+" units of Insulin", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
  
    
    func CalcCarbInsulinRatio(units: Int) -> Int {
        let PrevCarbIntake=500
        return PrevCarbIntake/units
    }
    
    func CalcInsulinSensitivity(units: Int) -> Int {
        let RuleVar=1800
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
 

    func CalcInsulin() -> Int {
        let sumofunits=40 //get yesterdays sum of units
        let InsulinUnits=(MealCarbs/CalcCarbInsulinRatio(units: sumofunits))+((nowBGL-targetBGL)/CalcInsulinSensitivity(units: sumofunits))-CalcExerciseComponent()
       return InsulinUnits
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
