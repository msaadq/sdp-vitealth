//
//  InsulinType.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 4/12/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import Foundation
struct Insulin {
    
    
    struct RapidAction{
        static let onset = 15
        static let peakactionmin = 30
        static let peakactionmax = 90
        static let activationtimemin = 180
        static let activationtimemax = 300
        
        
    }
    
    struct Regular{
        static let onset = 30
        static let peakactionmin = 120
        static let peakactionmax = 240
        static let activationtimemin = 360
        static let activationtimemax = 480
        
        
    }
   
    struct LongAction{
        struct Ultralente{
            static let onsetmin = 240
            static let onsetmax = 480
            static let peakactionmin = 720
            static let peakactionmax = 1080
            static let activationtimemin = 1440
            static let activationtimemax = 1680
            
        }
        struct Lantus{
            static let onsetmin = 120
            static let onsetmax = 240
            static let peakaction = 0
            static let activationtime = 1440
            
        }
        
    }
    struct InterAction{
        
        static let onsetmin = 60
        static let onsetmax = 180
        static let peakactionmin = 360
        static let peakactionmax = 720
        static let activationtimemin = 1080
        static let activationtimemax = 1440
        
        
    }
    
}
