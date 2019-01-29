//
//  Point.swift
//  comp1601_a3
//
//  Created by Stephanie Wang on 2018-03-22.
//  Copyright © 2018 COMP1601. All rights reserved.
//

import Foundation

class Projectile {
    var x_pos: Double
    var y_pos: Double
    var x_vel: Double
    var y_vel: Double
    var height: Double
    var init_v: Double
    
    let acceleration = -9.8
    
    init(x: Double, y: Double, v: Double, a: Double, h: Double) {
        self.x_vel = v*(cos(a*Double.pi/180))
        self.y_vel = v*(sin(a*Double.pi/180))
        self.height = h
        self.x_pos = x
        self.y_pos = y + h
        self.init_v = v*(sin(a*Double.pi/180))
    }
    
    func advance(deltaT: Double){
        if(self.y_pos >= getMaxHeight(velocity: self.init_v, height: self.height)){
            self.y_vel = -self.y_vel
        }
        self.y_vel += acceleration*deltaT
        self.y_pos += (self.y_vel-(4.9*deltaT))*deltaT
        if(y_pos < 0){
            y_pos = 0
        }
        if(self.y_pos > 0){
            self.x_pos += self.x_vel*deltaT
        }
    }
    
    func getMaxHeight(velocity: Double, height:Double) -> Double{
        let time = velocity/(-acceleration)
        let max_height = (velocity*time+(acceleration/2.0*time*time))+height
        return max_height;
    }
    
}

