//
//  Dose.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 4/15/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import Foundation
import Firebase
class Dose: NSObject {
    var insulinQuant:Int = 0
    var mealCarbs:Int=0
    var insulinType = "None"
    var glucose:Int = 0
    var user="None"
    var timeStamp:String=String(describing: NSDate())
    var timeofday:Int=0
    var basal:Bool=false
    
    override init(){}
    init(insulinQuant:Int,mealCarbs:Int,insulinType:String,glucose:Int,user:String,timeStamp:String,timeofday:Int,basal:Bool){
        self.insulinQuant=insulinQuant
        self.mealCarbs=mealCarbs
        self.insulinType = insulinType
        self.glucose = glucose
        self.user=user
        self.timeStamp=timeStamp
        self.timeofday=timeofday
        self.basal=basal
    }
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.insulinQuant = snapshotValue["insulinQuant"] as! Int
        self.mealCarbs = snapshotValue["mealCarbs"] as! Int
        self.insulinType = snapshotValue["insulinType"] as! String
        self.glucose=snapshotValue["glucose"] as! Int
        self.user=snapshotValue["user"] as! String
        self.timeStamp=snapshotValue["timeStamp"] as! String
        self.timeofday=snapshotValue["timeofday"] as! Int
        self.basal=snapshotValue["basal"] as! Bool

            }
    
    
    func toAnyObject() -> Any {
        return [
            "insulinQuant": insulinQuant,
            "mealCarbs":mealCarbs,
            "insulinType": insulinType,
            "glucose": glucose,
            "user": user,
            "timeStamp": timeStamp,
            "timeofday":timeofday,
            "basal":basal
        ]
    }
}
