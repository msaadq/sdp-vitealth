//
//  Dose.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 4/15/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import Foundation

class Dose: NSObject {
    var insulinQuant:Int = 0
    var insulinType = "None"
    var glucose:Int = 0
    var user="None"
    var timeStamp:String=String(describing: NSDate())
    
    override init(){}
    init(insulinQuant:Int,insulinType:String,glucose:Int,user:String,timeStamp:String){
        self.insulinQuant=insulinQuant
        self.insulinType = insulinType
        self.glucose = glucose
        self.user=user
        self.timeStamp=timeStamp
    }
    
    
    func toAnyObject() -> Any {
        return [
            "insulinQuant": insulinQuant,
            "insulinType": insulinType,
            "glucose": glucose,
            "user": user,
            "timeStamp": timeStamp
        ]
    }
}
