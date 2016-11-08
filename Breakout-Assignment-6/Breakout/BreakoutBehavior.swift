//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Tatiana Kornilova on 9/4/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit

// MARK: - CLASS BreakoutBehavior

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    var hitBreak : ((_ behavior: UICollisionBehavior, _ ball: BallView, _ brickIndex: Int)-> ())?
    var leftPlayingField : ((BallView)-> ())?
    
    var gravityOn: Bool  = true
    let gravity = UIGravityBehavior()
    var gravityMagnitudeModifier:CGFloat = 0.0 {
        didSet{
            gravity.magnitude = gravityMagnitudeModifier
        }
    }
    
    // MARK: - COLLIDER    
    private lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = false
        lazyCollider.collisionDelegate = self
        lazyCollider.action = { [unowned self] in
            
            for ball in self.balls {
                if !self.dynamicAnimator!.referenceView!.bounds.intersects(ball.frame){
                     self.leftPlayingField?( ball as BallView)
                }
                
                self.ballBehavior.limitLinearVelocity(Constants.Ball.MinVelocity,
                                                 max: Constants.Ball.MaxVelocity,
                                             forItem: ball as BallView)
            }
        }
        return lazyCollider
        }()
    
    // MARK: - ballBehavior
   lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazyBallBehavior = UIDynamicItemBehavior()
        lazyBallBehavior.allowsRotation = false
        lazyBallBehavior.elasticity = 1.0
        lazyBallBehavior.friction = 0.0
        lazyBallBehavior.resistance = 0.0
        return lazyBallBehavior
        }()
    
    var balls: [BallView] {
        get { return collider.items.filter{$0 is BallView}.map{$0 as! BallView} }
    }
    
    // MARK: - INIT
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }
    
    // MARK: - BOUNDARIES
    func addBoundary(_ path: UIBezierPath, named identifier: NSCopying) {
        removeBoundary(identifier)
        collider.addBoundary(withIdentifier: identifier, for: path)
    }
    
    func removeBoundary (_ identifier: NSCopying) {
        collider.removeBoundary(withIdentifier: identifier)
    }
    
     // MARK: - COLLISION BEHAVIOR
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem,
                                                 withBoundaryIdentifier boundaryId: NSCopying?,
                                                                         at p: CGPoint) {
        if let brickIndex = boundaryId as? Int {
            if let ball = item as? BallView {
                  self.hitBreak?(behavior, ball, brickIndex)
              }
        }
    }
    
    // MARK: - BALL
    func addBall(_ ball: UIView) {
        
        self.dynamicAnimator?.referenceView?.addSubview(ball)
        if gravityOn == true { gravity.addItem(ball) }
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(_ ball: UIView) {
        gravity.removeItem(ball)
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }
    
    func removeAllBalls(){
        for ball in balls {
            removeBall(ball)
        }
    }
    
    //  тормозим мячик
    func stopBall(_ ball: UIView) -> CGPoint {
        let linVeloc = ballBehavior.linearVelocity(for: ball)
        ballBehavior.addLinearVelocity(CGPoint(x: -linVeloc.x, y: -linVeloc.y), for: ball)
        return linVeloc
    }
    
    //  запускаем мячик после торможения
    func startBall(_ ball: UIView, velocity: CGPoint) {
        ballBehavior.addLinearVelocity(velocity, for: ball)
    }
    
    //запуск мячика push
    func launchBall(_ ball: UIView, magnitude: CGFloat) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: .instantaneous)
        pushBehavior.magnitude = magnitude
        let angle = CGFloat(1.25 * M_PI + (0.5 * M_PI) * (Double(arc4random()) / Double(UINT32_MAX)))
        pushBehavior.angle = angle

        pushBehavior.action = { [weak pushBehavior] in
            if !pushBehavior!.active { self.removeChildBehavior(pushBehavior!) }
        }
        
        addChildBehavior(pushBehavior)
    }
    
    func linearVelocityBall (_ item: UIDynamicItem) -> CGPoint {
        return ballBehavior.linearVelocity(for: item)}
 
   private struct Constants {
        struct Ball {
            static let MinVelocity = CGFloat(100.0)
            static let MaxVelocity = CGFloat(1400.0)
        }
    }

}
// MARK: - LINEAR VELOCITY


private extension UIDynamicItemBehavior {
    
    func limitLinearVelocity(_ min: CGFloat, max: CGFloat, forItem item: UIDynamicItem) {
        assert(min < max, "min < max")
        let itemVelocity = linearVelocity(for: item)
        (item as! BallView).backgroundColor = UIColor.white
        switch itemVelocity.magnitude {
        case  let x where x < CGFloat(600.0) :
            (item as! BallView).backgroundColor = UIColor.yellow
        case  let x where x < 800 && x >= 600 :
            (item as! BallView).backgroundColor = UIColor.orange
        case  let x where x  < 1000 && x >= 800 :
            (item as! BallView).backgroundColor = UIColor.red
        case  let x where  x >= 1000 :
            (item as! BallView).backgroundColor = UIColor.magenta
        default:
            (item as! BallView).backgroundColor = UIColor.white
        }
        if itemVelocity.magnitude <= 0.0 { return }
        if itemVelocity.magnitude < min {
            let deltaVelocity = min/itemVelocity.magnitude * itemVelocity - itemVelocity
            //                println ("magnitude = \(itemVelocity.magnitude) delta = \(deltaVelocity)")
            addLinearVelocity(deltaVelocity, for: item)
        }
        if itemVelocity.magnitude > max  {
            //            println(itemVelocity.magnitude )
            (item as! BallView).backgroundColor = UIColor.red
            let deltaVelocity = max/itemVelocity.magnitude * itemVelocity - itemVelocity
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
