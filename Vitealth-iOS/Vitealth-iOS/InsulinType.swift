//
//  File.swift
//  Vitealth-iOS
//
//  Created by Javeria Afzal on 4/12/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import Foundation
struct Insulin {
    
    
    struct RapidAction{
        static let onset = 15.0
        static let peakaction = 30.0...90.0
        static let activationtime = 180.0...300.0
        
        
    }
    
    struct Regular{
        static let onset = 30.0
        static let peakaction = 120.0...240.0
        static let activationtime = 360.0...480.0
        
        
    }
   
    struct LongAction{
        struct Ultralente{
            static let onset = 240.0...480.0
            static let peakaction = 720.0...1080.0
            static let activationtime = 1440.0...1680.0
            
        }
        struct Lantus{
            static let onset = 120.0...240.0
            static let peakaction = 0
            static let activationtime = 1440
            
        }
        
    }
    struct InterAction{
        static let onset = 60.0...180.0
        static let peakaction = 360.0...720.0
        static let activationtime = 1080.0...1440.0
        
        
    }
    
}
