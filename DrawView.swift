//
//  DrawView.swift
//  IOSTouch
//
//  Created by Stephanie Wang on 2018-03-27.
//  Copyright © 2018 COMP1601. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class DrawView: UIView {
    var currentLine: Line?
    var bottomLine: Line?
    var finishedDots = [Circle]();
    var theoreticalDots = [Circle]();
    var currentCircle: Circle?
    var dotCircle: Circle?
    var theoreticalCircle: Circle?
    
    var timer :Timer!
    var timerIsRunning = false
    
    var lineThickness = CGFloat(1.0);
    
    var euler = Projectile(x:0.0,y:0.0,v:0.0,a:0,h:0.0)
    
    //for debug
    let line3 = Line(begin: CGPoint(x:50,y:50), end: CGPoint(x:100,y:100));
    let line4 = Line(begin: CGPoint(x:50,y:100), end: CGPoint(x:100,y:300));
    
    func runTimer() {
        if timerIsRunning {return}
        timer = Timer.scheduledTimer(timeInterval: -0.5, //means 0.1 msec interval
            target: self,
            selector: (#selector(DrawView.updateTimer)),
            userInfo: nil,
            repeats: true)
        timerIsRunning = true
    }
    
    var count = 0
    @objc func updateTimer(){
        count = (count + 1) % 1000 //one event per 100 msec
        if count != 0 {return}
        //what is added every count
        if currentLine != nil{
            var velocity_y = calculateVelocity(line: currentLine!)*sin(calculateDegree(line1: currentLine!, line2: bottomLine!)/360*3.14);
            var theoreticalPosition = velocity_y*Double(count)
            theoreticalPosition = theoreticalPosition-4.9*Double(count)*Double(count)+Double((currentLine?.end.y)!)
            theoreticalCircle = Circle(centre: CGPoint(x:(euler.x_pos+Double((currentLine?.end.x)!)),y:(Double((currentLine?.end.y)!)-euler.y_pos)), radius: 2.0);
            theoreticalDots.append(theoreticalCircle!);
        }
        
        for _ in stride(from: 0, to: 1000, by: 1){
            euler.advance(deltaT: 0.001);
            /*if currentCircle != nil{
                dotCircle = Circle(centre: CGPoint(x:(euler.x_pos+Double((currentLine?.end.x)!)),y:(Double((currentLine?.end.y)!)-euler.y_pos)), radius: 2.0);
                finishedDots.append(dotCircle!);
            }*/
            setNeedsDisplay();
        }
        //print(euler.y_pos);
        //setNeedsDisplay();
    }

    
    func strokeLine(line: Line){
        //Use BezierPath to draw lines
        let path = UIBezierPath();
        path.lineWidth = lineThickness;
        path.lineCapStyle = CGLineCap.round;
        
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke(); //actually draw the path
    }
    
    func strokeCircle(circle: Circle){
        //Use BezierPath to draw circle
        let path = UIBezierPath(ovalIn: CGRect(x: circle.centre.x - circle.radius,
                                               y: circle.centre.y - circle.radius,
                                               width: circle.radius*2,
                                               height: circle.radius*2))
        path.lineWidth = 15.0;
        path.fill()
        path.stroke(); //actually draw the path
    }
    
    func calculateDegree(line1: Line, line2: Line) -> Double{
        let x1 = abs(line1.end.x - line1.begin.x);
        let y1 = abs(line1.end.y - line1.begin.y);
        let x2 = abs(line2.end.x - line2.begin.x);
        let y2 = abs(line2.end.y - line2.begin.y);
        //print(String(describing: x1) + " " + String(describing: y1));
        //print(String(describing: x2) + " " + String(describing: y2));
        let dot = x1*x2 + y1*y2;
        let length1 = sqrt(Double(x1*x1+y1*y1));
        let length2 = x2;
        //print(length1);
        //print(length2);
        var degree = Double(dot)/(length1*Double(length2));
        degree = acos(degree)*180/3.14;
        return degree;
    }
    
    func calculateVelocity(line: Line) -> Double{
        let x1 = abs(line.end.x - line.begin.x);
        let y1 = abs(line.end.y - line.begin.y);
        let length = sqrt(Double(x1*x1+y1*y1));
        return length;
    }
    
    override func draw(_ rect: CGRect) {
        // set the text color to dark gray
        let fieldColor: UIColor = UIColor.darkGray
        // set the font to Helvetica Neue 18
        let fieldFont = UIFont(name: "Helvetica Neue", size: 18)
        // set the line spacing to 6
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        // set the Obliqueness to 0.1
        let skew = 0.1
        var ticks = 100;
        
        let attributes: NSDictionary = [
            NSAttributedStringKey.foregroundColor: fieldColor,
            NSAttributedStringKey.paragraphStyle: paraStyle,
            NSAttributedStringKey.obliqueness: skew,
            NSAttributedStringKey.font: fieldFont!
        ]
        
        if !timerIsRunning {runTimer()}
        var highestVal = 0;
        if(rect.maxX < rect.maxY){
            highestVal = Int(rect.maxY);
        }
        else{
            highestVal = Int(rect.maxX);
        }
        for index in stride(from: 0, to: highestVal, by: 10){
            let line1 = Line(begin: CGPoint(x:0,y:index),end: CGPoint(x:rect.maxX,y:CGFloat(index)));
            let line2 = Line(begin: CGPoint(x:index,y:0), end: CGPoint(x:CGFloat(index),y:rect.maxY));
            if(index%50 == 0){
                lineThickness = CGFloat(2.0);
                let tick: NSString = String(ticks*2) as NSString;
                tick.draw(in: CGRect(x:CGFloat(ticks-20), y:CGFloat(rect.maxY-50), width: 300.0, height: 48.0), withAttributes: attributes as? [NSAttributedStringKey : Any])
                ticks += 100;
                UIColor.blue.setStroke();
            }
            else{
                UIColor.black.setStroke();
                lineThickness = CGFloat(1.0);
            }
            strokeLine(line: line1);
            strokeLine(line: line2);
        }
        if let line = currentLine {
            UIColor.magenta.setStroke(); //current line in red
            lineThickness = CGFloat(5.0);
            strokeLine(line: line);
            UIColor.gray.setStroke();
            strokeLine(line: bottomLine!);
            //print(calculateDegree(line1: currentLine!, line2: bottomLine!));
            let d = String(format:"%.2f",calculateDegree(line1: currentLine!, line2: bottomLine!)) + "degrees";
            let v = String(format:"%.2f",calculateVelocity(line: currentLine!)) + "m/s";
            let s: NSString = d as NSString;
            let s1: NSString = v as NSString;
            s.draw(in: CGRect(x:(bottomLine?.begin.x)!, y:(bottomLine?.begin.y)!, width: 300.0, height: 48.0), withAttributes: attributes as? [NSAttributedStringKey : Any])
            s1.draw(in: CGRect(x:(currentLine?.end.x)!, y:(currentLine?.end.y)!, width: 300.0, height: 48.0), withAttributes: attributes as? [NSAttributedStringKey : Any])

        }
        if let circle = currentCircle{
            UIColor.purple.setStroke();
            strokeCircle(circle: circle);
            dotCircle = Circle(centre: CGPoint(x:(euler.x_pos+Double((currentLine?.end.x)!)),y:(Double((currentLine?.end.y)!)-euler.y_pos)), radius: 2.0);
            finishedDots.append(dotCircle!);
            UIColor.black.setStroke();
            for dot in finishedDots{
                strokeCircle(circle: dot);
            }
           
            /*UIColor.red.setStroke();
            for dot1 in theoreticalDots{
                strokeCircle(circle: dot1);
            }
            */
            //strokeCircle(circle: dotCircle!);
        }
    }
    
    var temp = CGFloat(0.0);
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function) //for debugging
        let touch = touches.first!; //get first touch event and unwrap optional
        let location = touch.location(in: self); //get location in view co-ordinate
        currentLine = Line(begin: location, end: location);
        bottomLine = Line(begin: location, end: location);
        currentCircle = nil;
        temp = location.y;
        finishedDots = [Circle]();
        theoreticalDots = [Circle]();
        theoreticalCircle = nil;
        setNeedsDisplay(); //this view needs to be updated
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function) //for debugging
        let touch = touches.first!; //get first touch event and unwrap optional
        let location = touch.location(in: self); //get location in view co-ordinate
        currentLine?.end = location;
        bottomLine?.end = CGPoint(x:location.x,y:temp);
        setNeedsDisplay(); //this view needs to be updated
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function) //for debugging
        let touch = touches.first!; //get first touch event and unwrap optional
        let location = touch.location(in: self); //get location in view co-ordinate
        currentCircle = Circle(centre: location, radius: 3.0)
        var temp = Float((currentLine?.end.y)!)-Float((currentLine?.begin.y)!)
        //euler = Projectile(x:Double((currentLine?.end.x)!),y:Double((currentLine?.end.y)!),v:calculateVelocity(line: currentLine!),a:calculateDegree(line1: currentLine!, line2: bottomLine!),h:Double(temp))
        euler = Projectile(x: 0.0, y: 0.0, v:calculateVelocity(line: currentLine!), a:calculateDegree(line1: currentLine!, line2: bottomLine!),h:Double(temp));
        setNeedsDisplay(); //this view needs to be updated
    }
}


