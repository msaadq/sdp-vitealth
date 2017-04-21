//
//  Constants.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 3/22/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//
import Foundation
struct Constants {
    struct Firebase{
        static let BASE_URL = "https://vitealth-a8c1a.firebaseio.com/"
    }
    
    struct Nutritionix{
        static let APIBaseURL = "https://api.nutritionix.com/v1_1"
        static let scheme = "https"
        static let host = "api.nutritionix.com"
        static let path = "/v1_1/search"
        
    }
    
    // MARK:  Parameter Keys
    struct NutritionixParameterKeys {
        
        static let APIKey = "appKey"
        static let APPID = "appId"
        static let results = "results"
        static let cal_min = "cal_min"
        static let cal_max = "cal_max"
        static let fields = "fields"
    }
    
    // MARK: Parameter Values
    struct NutritionixParameterValues {
        static let APIKey = "0db4f9cd152dd0f14208a56c667abcba"
        static let APPID = "744bc4b0"
        static let results = "0:20"
        static let cal_min = "0"
        static let cal_max = "50000"
        static let fields="item_name,brand_name,item_id,brand_id,nf_calories,nf_total_carbohydrate"
    }
    
    // MARK:  Response Keys
    struct NutritionixResponseKeys {
        static let Name = "item_name"
        static let ID = "item_id"
        static let Brand = "brand_name"
        static let Calories = "nf_calories"
        static let Carbs = "nf_total_carbohydrate"
        static let Serving = "nf_serving_size_qty"
    }
    
    
}



