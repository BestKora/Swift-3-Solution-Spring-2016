//
//  Extensions.swift
//  Breakout
//
//  Copyright (c) 2015 private. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func `repeat`(_ n:Int) -> String {
        if n <= 0 { return "" }
        
        var result = self
        for _ in 1 ..< n { result += self }
        return result
    }
}

// MARK: - LINEAR VELOCITY

extension UIDynamicItemBehavior {
    
    func limitLinearVelocity(min: CGFloat, max: CGFloat,
                             forItem item: UIDynamicItem) {
        guard min < max else {return}
        
        let itemVelocity = linearVelocity(for: item)
        if itemVelocity.magnitude <= 0.0 { return }
        
        (item as? UIView)?.backgroundColor = UIColor.white
        switch itemVelocity.magnitude {
        case  let x where x < CGFloat(600.0) && x >= min :
            (item as? UIView)?.backgroundColor = UIColor.yellow
        case  let x where x < 800 && x >= 600 :
            (item as? UIView)?.backgroundColor = UIColor.orange
        case  let x where x  < 1000 && x >= 800 :
            (item as? UIView)?.backgroundColor = UIColor.red
        case  let x where  x >= 1000 :
            (item as? UIView)?.backgroundColor = UIColor.magenta
        default:
            (item as? UIView)?.backgroundColor = UIColor.white
        }
        
        if itemVelocity.magnitude < min {
            let deltaVelocity =
                min/itemVelocity.magnitude * itemVelocity - itemVelocity
            addLinearVelocity(deltaVelocity, for: item)
        }
        if itemVelocity.magnitude > max  {
            (item as? UIView)?.backgroundColor = UIColor.magenta
            let deltaVelocity =
                max/itemVelocity.magnitude * itemVelocity - itemVelocity
            addLinearVelocity(deltaVelocity, for: item)
        }
    }
}

private extension CGPoint {
    var angle: CGFloat {
        get { return CGFloat(atan2(self.x, self.y)) }
    }
    var magnitude: CGFloat {
        get { return CGFloat(sqrt(self.x*self.x + self.y*self.y)) }
    }
}

prefix func -(left: CGPoint) -> CGPoint {
    return CGPoint(x: -left.x, y: -left.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x-right.x, y: left.y-right.y)
}

func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left*right.x, y: left*right.y)
}
