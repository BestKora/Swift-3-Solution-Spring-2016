//
//  BreakoutView.swift
//  Breakout
//
//  Created by Tatiana Kornilova on 9/4/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreMotion

class BreakoutView: UIView {

    // MARK: Public API
    
    var animating: Bool = false {
        didSet {
            if animating {
                animator.addBehavior(behavior)
                updateRealGravity()
            } else {
                animator.removeBehavior(behavior)
            }
        }
    }
    var realGravity: Bool = false {
        didSet {
            updateRealGravity()
        }
    }

     var behavior = BreakoutBehavior()
     var bricks =  [Int:BrickView]()
     var balls: [BallView]  {return self.behavior.balls}
    var gravityMagnitudeModifier:CGFloat = 0.0 {
        didSet {
            behavior.gravityMagnitudeModifier = gravityMagnitudeModifier
        }
    }
    
    var levelInt: Int?  {
        didSet {
            if let levelNew = levelInt {
                level = Levels.levels [levelNew]
            }
        }
    }

    var paddleWidthPercentage :Int = Constants.PaddleWidthPercentage {
        didSet{
            if  paddleWidthPercentage == oldValue{ return}
            resetPaddleInCenter()
        }
    }
    
    var launchSpeedModifier: Float = 0.0
    
    // MARK: Private Implementation
    
    private var level :[[Int]]? {
        didSet {
            reset()
        }
    }

    private lazy var animator: UIDynamicAnimator = {
        UIDynamicAnimator(referenceView: self)
        }()
    
   private lazy var paddle: PaddleView = {
        let paddle = PaddleView(frame: CGRect(origin: CGPoint.zero,
            size: self.paddleSize))
        self.addSubview(paddle)
        return paddle
        }()
    
    
    private var launchSpeed:CGFloat{
        get {return Constants.minLaunchSpeed +
            (Constants.maxLaunchSpeed - Constants.minLaunchSpeed) * CGFloat(launchSpeedModifier)}
    }

    private var columns: Int?{
        get {return level?[0].count}
    }

    // MARK: - LIFE CYCLE
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resetPaddlePosition()
        // Помещаем balls обратно в breakoutView после автовращения
        for ball in balls {
            if !self.bounds.contains(ball.frame) {
                placeBallBack(ball)
            }
        }
    }
    
    func resetLayout() {
        var gameBounds = self.bounds
        gameBounds.size.height *= 2.0
        behavior.addBoundary(UIBezierPath(rect: gameBounds), named: Constants.selfBoundaryId as NSCopying)
        resetPaddleInCenter()
        resetBricks()
    }
    
    func reset(){
        removeBricks()
        removeAllBalls()
        createBricks()
        resetPaddleInCenter()
    }
    
    // MARK: - BALLS
    
    func addBall() {
        let ball = BallView(frame: CGRect(origin: CGPoint(x: paddle.center.x,
                                y: paddle.frame.minY - Constants.BallSize.height),
                             size: Constants.BallSize))
        self.behavior.addBall(ball)
        behavior.launchBall(ball, magnitude: launchSpeed)
    }
    
    func removeBall(_ ball: BallView){
        self.behavior.removeBall(ball)
    }
    
    func removeAllBalls(){
        behavior.removeAllBalls()
    }
    
    func pushBalls(){
        for ball in balls {
            behavior.launchBall(ball, magnitude: Constants.pushSpeed)
        }
    }
    
    private func placeBallBack(_ ball: UIView) {
 
        ball.center = CGPoint(x: self.paddle.center.x,
                              y: self.paddle.center.y - paddle.bounds.height * 3)
        animator.updateItem(usingCurrentState: ball)
    }
    
    var ballVelocity: [CGPoint]
        {
        get {
            var ballVelocityLoc = [CGPoint]()
            for ball in balls {
                ballVelocityLoc.append(behavior.stopBall(ball))
            }
            return ballVelocityLoc
        }
        set {
            var ballVelocityLoc = newValue as [CGPoint]
            if !newValue.isEmpty {
                for i in 0..<balls.count {
                    behavior.startBall(behavior.balls[i], velocity: ballVelocityLoc[i])
                }
            }
        }
    }
    
    // MARK: - BRICKS
    
    private func createBricks() {
        if let arrangement = level {
            
            if arrangement.count == 0 { return }    // нет строк
            if arrangement[0].count == 0 { return } // нет столбцов
            
            let rows = arrangement.count
            let columns = arrangement[0].count
            let width = (self.bounds.size.width -
                             2 * Constants.BrickSpacing) / CGFloat(columns)
            
            for row in 0 ..< rows {
                let columns = arrangement[row].count
                for column in 0 ..< columns {
                    if arrangement[row][column] == 0 { continue }
                    
                    let x = Constants.BrickSpacing + CGFloat(column) * width
                    let y = Constants.BricksTopSpacing +
                            CGFloat(row) * Constants.BrickHeight +
                            CGFloat(row) * Constants.BrickSpacing * 2
                    let hue = CGFloat(row) / CGFloat(rows)
                    createBrick(width, x: x, y: y, hue: hue)
                }
            }
        }
    }
    
    private func createBrick(_ width: CGFloat, x: CGFloat, y: CGFloat, hue: CGFloat) {
        var frame = CGRect(origin: CGPoint(x: x, y: y),
                             size: CGSize(width: width, height: Constants.BrickHeight))
        frame = frame.insetBy(dx: Constants.BrickSpacing, dy: 0)
        
        let brick = BrickView(frame: frame, hue: hue)
        bricks[bricks.count] = brick
        
        addSubview(brick)
        behavior.addBoundary( UIBezierPath(roundedRect: brick.frame,
                                          cornerRadius: brick.layer.cornerRadius),
                              named: (bricks.count - 1)  as NSCopying)
    }
    
    
  func removeBrick(_ brickIndex: Int) {
        behavior.removeBoundary(brickIndex as NSCopying)
        
        if let brick = bricks[brickIndex] {
            UIView.transition(with: brick, duration: 0.3,
                                              options: .transitionFlipFromBottom,
                                           animations: {
                brick.alpha = 0.5
                }, completion: { (success) -> Void in
                    UIView.animate(withDuration: 1.0, animations: {
                        brick.alpha = 0.0
                        }, completion: { (success) -> Void in
                            brick.removeFromSuperview()
                    })
            })
            
            bricks.removeValue(forKey: brickIndex)
        }
    }
    
    private func removeBrickWithoutAnimation(_ brickIndex: Int) {
        behavior.removeBoundary(brickIndex as NSCopying)
        
        if let brick = bricks[brickIndex] {
            brick.removeFromSuperview()
            bricks.removeValue(forKey: brickIndex)
        }
    }
    
    private func resetBricks(){
        let activeBricksSet = Set(bricks.keys)
        removeBricks()
        createBricks()
        for brick in bricks {
            let index = brick.0
            if  !activeBricksSet.contains(index) {
                removeBrickWithoutAnimation(brick.0)
            }
        }
    }
    
    private func removeBricks() {
        if bricks.count == 0 {return}
        for brick in bricks {
            removeBrickWithoutAnimation(brick.0)
        }
    }
    
    // MARK: - PADDLE
    
    private var paddleSize : CGSize {
        let width = self.bounds.size.width / 100.0 * CGFloat(paddleWidthPercentage)
        return CGSize(width: width, height: CGFloat(Constants.PaddleHeight))
    }
    
    private func translatePaddle(_ translation: CGPoint) {
        var newFrame = paddle.frame
        newFrame.origin.x = max( min(newFrame.origin.x + translation.x, self.bounds.maxX - paddle.bounds.size.width), 0.0)
        for ball in balls {
            if newFrame.contains(ball.frame) {
                return
            }
        }
        paddle.frame = newFrame;
        behavior.addBoundary(UIBezierPath(ovalIn: paddle.frame), named: Constants.paddleBoundaryId as NSCopying)
    }
    
    private func resetPaddleInCenter(){
        paddle.center = CGPoint.zero
        resetPaddlePosition()
    }
    
    private func resetPaddlePosition() {
        paddle.frame.size = paddleSize
        if !self.bounds.contains(paddle.frame) {
            paddle.center = CGPoint(x: self.bounds.midX,
                y: self.bounds.maxY - paddle.bounds.height - Constants.PaddleBottomMargin)
        } else {
            paddle.center = CGPoint(x: paddle.center.x,
                y: self.bounds.maxY - paddle.bounds.height - Constants.PaddleBottomMargin)
        }
        behavior.addBoundary(UIBezierPath(ovalIn: paddle.frame),
                             named: Constants.paddleBoundaryId as NSCopying)
    }
    
    //---- ОБРАБОТКА ЖЕСТОВ
    
    func panPaddle(_ gesture: UIPanGestureRecognizer) {
        let gesturePoint = gesture.translation(in: self)
        switch gesture.state {
        case .ended: fallthrough
        case .changed:
           translatePaddle(gesturePoint)
            gesture.setTranslation(CGPoint.zero, in:self)
        default: break
        }
    }
    
   //-------------------
    struct Constants {
        static let selfBoundaryId = "selfBoundary"
        static let paddleBoundaryId = "paddleBoundary"
      
        static let BallSize = CGSize(width: 20, height: 20)
        static let BallSpacing: CGFloat = 3
        
        static let PaddleBottomMargin: CGFloat = 10.0
        static let PaddleHeight: Int = 15
        static let PaddleColor = UIColor.white
        static let PaddleWidthPercentage:Int = 33
        
        
        static let BrickHeight: CGFloat = 20.0
        static let BrickSpacing: CGFloat = 5.0
        static let BricksTopSpacing: CGFloat = 20.0
        static let BrickSideSpacing: CGFloat = 10.0
        
        static let minLaunchSpeed = CGFloat(0.2)
        static let maxLaunchSpeed = CGFloat(0.5)
        static let pushSpeed = CGFloat(0.15)
        
    }
    // MARK: Core Motion
    
    private let motionManager = CMMotionManager()
    
    private func updateRealGravity() {
        if realGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.25
                motionManager.startAccelerometerUpdates(to: OperationQueue.main)
                { [unowned self] (data, error) in
                    if self.behavior.dynamicAnimator != nil {
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            switch UIDevice.current.orientation {
                            case .portrait: dy = -dy
                            case .portraitUpsideDown: break
                            case .landscapeRight: swap(&dx, &dy)
                            case .landscapeLeft: swap(&dx, &dy); dy = -dy
                            default: dx = 0; dy = 0;
                            }
                            self.behavior.gravity.gravityDirection = CGVector(dx: dx, dy: dy)
                        }
                    } else {
                        self.motionManager.stopAccelerometerUpdates()
                    }
                }
            }
        } else {
            motionManager.stopAccelerometerUpdates()
        }
    }

}
