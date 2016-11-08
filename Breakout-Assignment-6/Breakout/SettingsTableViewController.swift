//
//  SettingsTableViewController.swift
//  Breakout
//
//  Copyright (c) 2015 private. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var levelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var paddleWidthSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ballCountLabel: UILabel!
    @IBOutlet weak var ballCountStepper: UIStepper!
    @IBOutlet weak var ballSpeedModifierSlider: UISlider!
    @IBOutlet weak var realGravitySwitch: UISwitch!
    @IBOutlet weak var gravityMagnitudeModifierSlider: UISlider!
    
     fileprivate let settings = Settings()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ballSpeedModifierSlider.value = settings.ballSpeedModifier
        ballCountStepper.value = Double(settings.maxBalls)
        ballCountLabel.text = "\(Int(ballCountStepper.value))"
        levelSegmentedControl.selectedSegmentIndex = settings.level
        realGravitySwitch.isOn = settings.realGravity
        gravityMagnitudeModifierSlider.value = settings.gravityMagnitudeModifier

        
        switch(settings.paddleWidth){
        case PaddleWidths.Small: paddleWidthSegmentedControl.selectedSegmentIndex = 0
        case PaddleWidths.Medium: paddleWidthSegmentedControl.selectedSegmentIndex = 1
        case PaddleWidths.Large: paddleWidthSegmentedControl.selectedSegmentIndex = 2
        default: paddleWidthSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func PaddleWidthChanged(_ sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex {
        case 0: settings.paddleWidth = PaddleWidths.Small
        case 1: settings.paddleWidth = PaddleWidths.Medium
        case 2: settings.paddleWidth = PaddleWidths.Large
        default: settings.paddleWidth = PaddleWidths.Medium
        }
    }
    
    @IBAction func levelChanged(_ sender: UISegmentedControl) {
        
        settings.level = sender.selectedSegmentIndex
    }
    
    
    @IBAction func ballCountChanged(_ sender: UIStepper)
    {
        settings.maxBalls = Int(ballCountStepper.value)
        ballCountLabel.text = "\(Int(ballCountStepper.value))"
    }
    
    @IBAction func ballSpeedModifierChanged(_ sender: UISlider)
    {
        settings.ballSpeedModifier = ballSpeedModifierSlider.value
    }
    
    @IBAction func realGravityChanged(_ sender: UISwitch) {
        settings.realGravity = sender.isOn

    }
    
    @IBAction func gravityMagnitudeModifierChanged(_ sender: UISlider) {
        settings.gravityMagnitudeModifier = gravityMagnitudeModifierSlider.value

    }
}

private struct PaddleWidths {
    static let Small = 20
    static let Medium = 33
    static let Large = 50
}
