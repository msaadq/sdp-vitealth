//
//  FoodOptionsViewController.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 3/2/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Foundation
class FoodOptionsViewController: UIViewController , SendMealBackProtocol{

    @IBOutlet weak var searchfood: UITextField!
    @IBOutlet weak var FindFoodButton: UIButton!
    @IBOutlet weak var DisplayLabel: UILabel!
 
    @IBOutlet weak var nextbutton: UIButton!
     var selectedOption=FoodItem()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        // Hiding keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FoodOptionsViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

   
    

 
    @IBAction func FindButtonPressed(_ sender: Any) {
        print("Successful button press")
        if searchfood.text?.isEmpty == true
        {
            let alert = UIAlertController(title: "Vitealth zPortal", message: "Please enter what you are eating", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            print("Nothing found")
            
            return

        }
        let foodentered = searchfood.text
        let foodenteredSpaceless = foodentered?.trimmingCharacters(in: .whitespaces)
        //print(foodentered ?? "Nothing")
        getMealData(food:foodenteredSpaceless!)
        
        print("Fetching")
        
       // display.text = "Fetching"
        
        //performSegue(withIdentifier: "loadDetails", sender: sender)
    }
    
    
    private func getMealData(food: String)
    {
        //make url
        var components = URLComponents()
        components.scheme = Constants.Nutritionix.scheme
        components.host = Constants.Nutritionix.host
        components.path = Constants.Nutritionix.path+"/"+food
        // components.query = food
        components.queryItems = [URLQueryItem]()
        
        
        
        
        let queryItem1 = URLQueryItem(name: Constants.NutritionixParameterKeys.results, value: Constants.NutritionixParameterValues.results)
        let queryItem2 = URLQueryItem(name: Constants.NutritionixParameterKeys.fields, value: Constants.NutritionixParameterValues.fields)
        let queryItem3 = URLQueryItem(name: Constants.NutritionixParameterKeys.APPID, value: Constants.NutritionixParameterValues.APPID)
        let queryItem4 = URLQueryItem(name: Constants.NutritionixParameterKeys.APIKey, value: Constants.NutritionixParameterValues.APIKey)
        
        components.queryItems!.append(queryItem1)
        components.queryItems!.append(queryItem2)
        components.queryItems!.append(queryItem3)
        components.queryItems!.append(queryItem4)
        
        print(components.url!)
        print("URL made")
        var urlString:String?
        print("abt to go to table")
        let gotoTable = storyboard?.instantiateViewController(withIdentifier: "FoodDetailsViewController") as! FoodDetailsViewController
        // do{
        
        urlString = components.url?.absoluteString
        print(urlString!)
        if urlString != nil
        {gotoTable.urlString = urlString!}
        //  }
        //  catch {print("something happnened")}
        gotoTable.delegate = self
        navigationController?.pushViewController(gotoTable, animated: true)
        
        
        
        
        
        
    }
    func setMealDisplay(valueSent: FoodItem)
    {
        
        var carbs:String?
        
        self.selectedOption = valueSent
        carbs=NSString(format: "%d", Int(valueSent.carbs)) as String
        if carbs != nil
        {self.DisplayLabel.text = "Your food contains:"+carbs!+" carbs"
        self.DisplayLabel.isHidden=false
        self.nextbutton.setTitle("Next", for: .normal)
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: Keyboard
    
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height / 2
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Create a variable that you want to send
        if(segue.identifier == "GotoGlucPage") {
            
            let yourNextViewController = (segue.destination as! GlucometerViewController)
            //let carbohydrates = Int((self.selectedOption.carbs)!)
                yourNextViewController.MealCarbs = Int(self.selectedOption.carbs)
           
        }
    }


    
}

