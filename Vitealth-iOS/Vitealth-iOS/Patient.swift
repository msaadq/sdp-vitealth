//
//  Patient.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 4/21/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import Foundation
class Patient: NSObject {
    var name:String? = nil
    var weight:Int = 0
    var height:Int = 0
    var ketone:Int = 0
    var h1bc:Int = 0
    var age:Int=0
    var gender:String? = nil
    var type:String? = nil
    var BloodType:String? = nil
    var basal :String? = nil
    var bolus :String? = nil
    var dremail:String? = nil
    var isNew:Bool=true
    var initialInsulin:Int=0
    var useremail:String? = nil
    var timeStamp:String? = nil
    var lastseen:Int = 0
    var isnewUser:Bool = true
    var sugarTarget:Int=0
    var drname:String?=nil
    var drphone:Int=0
    var drdesig:String?=nil
    var drlicense:String?=nil
   
    
    override init(){}
    init(name:String,weight:Int,height:Int,ketone:Int,h1bc:Int,age:Int,gender:String,type:String,BloodType:String,basal:String,bolus:String,isNew:Bool,initialInsulin:Int,dremail:String,useremail:String,timeStamp:String,lastseen:Int,isnewUser:Bool,sugarTarget:Int,drname:String,drphone:Int,drdesig:String,drlicense:String){
        self.name=name
        self.weight=weight
        self.height=height
        self.ketone=ketone
        self.h1bc=h1bc
        self.age=age
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
        self.lastseen=lastseen
        self.isnewUser=isnewUser
        self.sugarTarget=sugarTarget
        self.drname=drname
        self.drphone=drphone
        self.drdesig=drdesig
        self.drlicense=drlicense
    }
    
    
    func toAnyObject() -> Any {
        return [
            "name":name ?? "" ,
            "weight":weight,
            "height":height,
            "ketone":ketone,
            "h1bc":h1bc,
            "age":age,
            "gender":gender ?? "",
            "type":type ?? "",
            "BloodType":BloodType ?? "",
            "basal":basal ?? "",
            "bolus":bolus ?? "",
            "dremail":dremail ?? "",
            "isNew":isNew,
            "initialInsulin":initialInsulin,
            "useremail": useremail ?? "",
            "timeStamp": timeStamp ?? "",
            "lastseen": lastseen,
            "isnewUser":isnewUser,
            "sugarTarget":sugarTarget,
            "drname": drname ?? "",
            "drphone": drphone,
            "drdesig": drdesig ?? "",
            "drlicense":drlicense ?? ""
            
        ]
    }
}
