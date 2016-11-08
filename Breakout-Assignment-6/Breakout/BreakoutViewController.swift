//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Tatiana Kornilova on 9/4/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreMotion

class BreakoutViewController: UIViewController {

    @IBOutlet var breakoutView: BreakoutView!  {
        didSet {
            breakoutView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(BreakoutViewController.launchBall(_:))))
            breakoutView.addGestureRecognizer(UIPanGestureRecognizer(target: breakoutView, action: #selector(BreakoutView.panPaddle(_:))))
            breakoutView.behavior.hitBreak =  self.ballHitBrick
            breakoutView.behavior.leftPlayingField =  self.ballLeftPlayingField
        }
    }
  
    @IBOutlet var ballsLeftLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet weak var gravityLabel: UILabel!
    
    var maxBalls: Int = Settings().maxBalls {
        didSet { ballsLeftLabel?.text = "⦁".`repeat`(maxBalls - ballsUsed) }
    }
    
    var ballsUsed = 0 {
        didSet { ballsLeftLabel?.text = "⦁".`repeat`(maxBalls - ballsUsed) }
    }
    
    private var score = 0 {
        didSet{ scoreLabel?.text = "\(score)" }
    }
    
    private var ballVelocity = [CGPoint]()
    private var gameViewSizeChanged = true
    
    private let motionManager = CMMotionManager()
    private let settings = Settings()
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Переустановка при автовращении
        if gameViewSizeChanged {
            gameViewSizeChanged = false
            breakoutView.resetLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        breakoutView.animating = true
        loadSettings()
        
        //  Restart мячиков при возвращени на закладку Breakout игры
        breakoutView.ballVelocity = ballVelocity
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
          breakoutView.animating = false
        
        // Останавливаем мячики
         ballVelocity = breakoutView.ballVelocity
    }
    
    override func viewWillTransition(to size: CGSize,
                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        gameViewSizeChanged = true
    }

    // MARK: - GESTURES
    
    func launchBall(_ gesture: UITapGestureRecognizer){
        if gesture.state == .ended {
            if breakoutView.balls.count > 0 {
                     breakoutView.pushBalls()
            } else if ballsUsed < maxBalls {
                ballsUsed += 1
                breakoutView.addBall()
            }
        }
    }
    
    // MARK: - LOAD SEIITINGS
    private func loadSettings() {
        
        maxBalls = settings.maxBalls
        breakoutView.paddleWidthPercentage = settings.paddleWidth
        if breakoutView.levelInt != settings.level {
            breakoutView.levelInt = settings.level
        }
        breakoutView.launchSpeedModifier = settings.ballSpeedModifier
        breakoutView.realGravity = settings.realGravity
        breakoutView.gravityMagnitudeModifier = CGFloat(settings.gravityMagnitudeModifier)
        gravityLabel?.text = (formatter.string(from: NSNumber(value: settings.gravityMagnitudeModifier)) ?? "0.00") + " g"

    }
    
    // MARK: - RESET GAME
    private func resetGame()
    {
        breakoutView.reset()
        ballsUsed = 0
        score = 0
    }
    
    // MARK: - Hit BRICK
    func ballHitBrick(_ behavior: UICollisionBehavior, ball: BallView, brickIndex: Int) {
        breakoutView.removeBrick(brickIndex)
        score += 1
        if breakoutView.bricks.count == 0 {
            breakoutView.removeAllBalls()
            showGameEndedAlert(true, message: "ВЫИГРЫШ!")
        }
    }
    
    // MARK: - Ball LEFT Plaing FIELD
    func ballLeftPlayingField(_ ball: BallView)
    {
        if(ballsUsed == maxBalls) { // the last ball just left the playing field
            showGameEndedAlert(false, message: "Нет мячиков!")
        }
        breakoutView.removeBall(ball)
    }
    
    // MARK: - ALERT
    private func showGameEndedAlert(_ playerWon: Bool, message: String) {
        let title = playerWon ? Const.congratulationsTitle : Const.gameOverTitle
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) {
            (action) in
            self.resetGame()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            (action) in
            // do nothing
        })
        DispatchQueue.main.async {
            if self.presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true;
    }
    // on device shake
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        breakoutView.pushBalls()
    }
    
    private struct Const {
        static let gameOverTitle = "Game over!"
        static let congratulationsTitle = "Congratulations!"
         static let maxPaddleSpeed = 25.0
    }
}

let formatter:NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale.current
    return formatter
    
} ()

