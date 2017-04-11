//
//  FoodItem.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 3/22/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//



import UIKit

class FoodItem: NSObject {
    var name = "None"
    var brand = "None"
    var calories:Float = 0.0
    var carbs:Float=0.0
    override init(){}
    init(name:String,brand:String,calories:Float,carbs:Float){
        self.name = name
        self.brand = brand
        self.calories = calories
        self.carbs=carbs
    }
}


