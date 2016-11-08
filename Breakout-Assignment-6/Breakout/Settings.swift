//
//  Settings.swift
//  Breakout
//
//  Copyright (c) 2015 private. All rights reserved.
//

import Foundation

class Settings {
   struct Defaults {
        static let Level = 2
        static let BallSpeedModifier = Float(0.05)
        static let MaxBalls: Int = 3
        static let PaddleWidth = PaddleWidthPercentage.Large
        static let RealGravity = false
        static let GravityMagnitudeModifier = Float(0.00)
    }
    
    fileprivate struct Keys {
        static let Level = "Settings.Level"
        static let BallSpeedModifier = "Settings.BallSpeedModifier"
        static let MaxBalls = "Settings.BallCount"
        static let PaddleWidth = "Settings.PaddleWidth"
        static let RealGravity = "Settings.RealGravity"
        static let GravityMagnitudeModifier = "Settings.GravityMagnitudeModifier"
    }
    
    fileprivate let userDefaults = UserDefaults.standard
    
    // gameplay settings
    
    var level: Int {
        get { return (userDefaults.object(forKey: Keys.Level) as? Int) ?? Defaults.Level}
        set { userDefaults.set(newValue, forKey: Keys.Level) }
    }
    
    var ballSpeedModifier: Float {
        get { return userDefaults.object(forKey: Keys.BallSpeedModifier) as? Float ?? Defaults.BallSpeedModifier}
        set { userDefaults.set(newValue, forKey: Keys.BallSpeedModifier) }
    }
    
    var maxBalls: Int
    {
        get { return userDefaults.object(forKey: Keys.MaxBalls) as? Int ?? Defaults.MaxBalls }
        set { userDefaults.set(newValue, forKey: Keys.MaxBalls) }
    }
    
    var paddleWidth: Int
    {
        get{ return userDefaults.object(forKey: Keys.PaddleWidth) as? Int ?? Defaults.PaddleWidth}
        set{ userDefaults.set(newValue, forKey: Keys.PaddleWidth)}
        
    }
    
    var realGravity: Bool
        {
        get{ return userDefaults.object(forKey: Keys.RealGravity)  as? Bool ?? Defaults.RealGravity}
        set{ userDefaults.set(newValue, forKey: Keys.RealGravity)}
    }
    
    var gravityMagnitudeModifier: Float
        {
        get { return userDefaults.object(forKey: Keys.GravityMagnitudeModifier) as? Float ?? Defaults.GravityMagnitudeModifier}
        set { userDefaults.set(newValue, forKey: Keys.GravityMagnitudeModifier) }
    }

}

struct PaddleWidthPercentage {
    static let Small = 20
    static let Medium = 35
    static let Large = 50
}
