//
//  File.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 4/3/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

struct ExerciseParameters {
    
     // MARK:  70-99mgdm3
    struct LowBloodSugar{
        static let LongDurModInt = -1
        static let ModDurHighInt = -2
        static let ModDurModInt = -1
        static let ShortDurLowInt = -1
        
    }
     // MARK:  100-120mgdm3
    struct MedBloodSugar{
        static let LongDurModInt = -1
        static let ModDurHighInt = -1
        static let ModDurModInt = -1
        static let ShortDurLowInt = 0
        
    }
     // MARK:  121-179mgdm3
    struct MedHighBloodSugar{
        static let LongDurModInt = -1
        static let ModDurHighInt = -2
        static let ModDurModInt = 0
        static let ShortDurLowInt = 0
        
    }
    // MARK:  180-250mgdm3
    struct HighBloodSugar{
        static let LongDurModInt = -1
        static let ModDurHighInt = 0
        static let ModDurModInt = 0
        static let ShortDurLowInt = 0
        
    }
}

