//
//  Patient.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 4/21/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import Foundation
class Patient: NSObject {
    var weight:Int = 0
    var height:Int = 0
    var ketone:Int = 0
    var h1bc:Int = 0
    var birthdate:String=String(describing: NSDate())
    var gender="male"
    var type = "Type 2"
    var BloodType = "None"
    var basal = "None"
    var bolus = "None"
    
     var dremail="None"
    var isNew:Bool=true
    var initialInsulin:Int=0
    var useremail="None"
    var timeStamp:String=String(describing: NSDate())
   
    
    override init(){}
    init(weight:Int,height:Int,ketone:Int,h1bc:Int,birthdate:String,gender:String,type:String,BloodType:String,basal:String,bolus:String,isNew:Bool,initialInsulin:Int,dremail:String,useremail:String,timeStamp:String){
        self.weight=weight
        self.height=height
        self.ketone=ketone
        self.h1bc=h1bc
        self.birthdate=birthdate
        self.gender=gender
        self.type=type
        self.BloodType=BloodType
        self.basal=basal
        self.bolus=bolus
        self.dremail=dremail
        self.isNew=isNew
        self.initialInsulin=initialInsulin
        self.useremail=useremail
        self.timeStamp=timeStamp
    }
    
    
    func toAnyObject() -> Any {
        return [
            "weight":weight,
            "height":height,
            "ketone":ketone,
            "h1bc":h1bc,
            "birthdate":birthdate,
            "gender":gender,
            "type":type,
            "BloodType":BloodType,
            "basal":basal,
            "bolus":bolus,
            "dremail":dremail,
            "isNew":isNew,
            "initialInsulin":initialInsulin,
            "useremail": useremail,
            "timeStamp": timeStamp
        ]
    }
}
