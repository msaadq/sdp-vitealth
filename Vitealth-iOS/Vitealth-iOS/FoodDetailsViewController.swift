//
//  FoodDetailsViewController.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 3/22/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//


import UIKit

protocol SendMealBackProtocol {
    func setMealDisplay(valueSent: FoodItem)
}
class FoodDetailsViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var table: UITableView!
    var urlString:String = "default"
    var TableData=[FoodItem]()
    var delegate:SendMealBackProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self

        print("table entered")
        get_data_from_url(urlString)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return TableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FoodDetailsTableViewCell
        
        cell.name.text = TableData[indexPath.row].name
        cell.brand.text = TableData[indexPath.row].brand
        cell.calories.text =  NSString(format: "%d", Int(TableData[indexPath.row].calories)) as String
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        
        
        delegate?.setMealDisplay(valueSent: TableData[indexPath.row])
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    
    func get_data_from_url(_ link:String)
    {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            print(data ?? "No data")
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            if error == nil {
                if let data = data {
                    
                    self.extract_json(data)
                }
            }
            
            
        })
        
        task.resume()
        
    }
    
    func extract_json(_ data: Data)
    {
        
        
        let parsedResult: [String:AnyObject]!
        
        do
        {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            print("Successful entered!!")
        } catch {
            print("Could not parse the data as JSON: ")
            return
        }
        
        print(parsedResult)
        
        
        if let HitArray = parsedResult["hits"] as? [[String:AnyObject]]
        { //if2
            print("Entered deep")
            for i in 0 ..< HitArray.count
            {
                
                
                
                if let MealJsonObj = HitArray[i] as? NSDictionary
                {
                    if let MealFeatures = MealJsonObj["fields"] as? [String: AnyObject]
                    {
                        
                        let foodname = MealFeatures["item_name"] as? String
                        print(foodname ?? "Not found" )
                        //self.foodlabel.text="Food: "+foodname!
                        let foodbrand = MealFeatures["brand_name"] as? String
                        print(foodbrand ?? "Not found" )
                        //self.brandlabel.text="Brand: "+foodbrand!
                        let foodcalories = MealFeatures["nf_calories"] as? Float
                        print(foodcalories ?? "Not found" )
                        //self.callabel.text="Calories: "+"\(foodcalories)"
                        let foodcarbs = MealFeatures["nf_total_carbohydrate"] as? Float
                        print(foodcarbs ?? "Not found" )
                        //self.carblabel.text="Carb ratio: "+"\(foodcarbs)"
                        
                        self.TableData.append(FoodItem(name: foodname!,brand: foodbrand!,calories: foodcalories!,carbs: foodcarbs!))
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    }
                }
            }
        }//if2
        
        
        DispatchQueue.main.async(execute: {self.do_table_refresh()})
        
        
    }
    
    
    func do_table_refresh()
    {
        self.table.reloadData()
        
    }
    
    
}
