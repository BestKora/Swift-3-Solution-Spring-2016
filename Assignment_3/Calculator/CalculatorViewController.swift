//
//  ViewController.swift
//  Calculator
//
//  Created by Tatiana Kornilova on 5/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    @IBOutlet weak var history: UILabel!
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var graph: UIButton!{
        didSet{
            graph.enabled = false
        }
    }
    private struct Storyboard{
        static let ShowGraph = "Show Graph"
    }
    
    private var userIsInTheMiddleOfTyping = false
    let decimalSeparator = formatter.decimalSeparator ?? "."
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
//----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit !=  decimalSeparator) && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
//--------------------------------------------------

            if (digit != decimalSeparator) || (textCurrentlyInDisplay.rangeOfString(decimalSeparator) == nil) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var resultValue: (Double, String?) = (0.0, nil) {
        didSet {
            graph.enabled = !brain.isPartialResult
            switch resultValue {
            case (_, nil) : displayValue = resultValue.0
            case (_, let error):
                display.text = error
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    private var displayValue: Double? {
        get {
            if let text = display.text,
                value = formatter.numberFromString(text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.stringFromNumber(value)
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            } else {
                display.text = "0"
                history.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    private var brain = CalculatorBrain()
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    private struct Keys {
        static let Program = "CalculatorViewController.Program"
    }
    
    typealias PropertyList = AnyObject
    
    private var program: PropertyList? {
        get { return defaults.objectForKey(Keys.Program) }
        set { defaults.setObject(newValue, forKey: Keys.Program) }
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let value = displayValue{
                brain.setOperand(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(mathematicalSymbol)
        }
        resultValue  = brain.result
    }
    
    @IBAction func clearAll(sender: UIButton) {
        brain.clearVariables()
        brain.clear()
        displayValue = nil
    }
    
    @IBAction func backspace(sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            display.text!.removeAtIndex(display.text!.endIndex.predecessor())
            if display.text!.isEmpty {
                userIsInTheMiddleOfTyping  = false
                resultValue = brain.result
            }
        } else {
            brain.undoLast()
            resultValue = brain.result
        }
    }
    
    @IBAction func plusMinus(sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            if (display.text!.rangeOfString("-") != nil) {
                display.text = String((display.text!).characters.dropFirst())
            } else {
                display.text = "-" + display.text!
            }
        } else {
            performOperation(sender)
        }
    }
    
    @IBAction func setM(sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        if let value = displayValue {
            brain.variableValues[symbol] = value
            resultValue = brain.result
        }
    }
    
    
    @IBAction func pushM(sender: UIButton) {
        brain.setOperand(sender.currentTitle!)
        resultValue = brain.result
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String,
                                                   sender: AnyObject?) -> Bool {
        return !brain.isPartialResult
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let gVC = segue.destinationViewController.contentViewController
                                                           as? GraphViewController
            where segue.identifier == Storyboard.ShowGraph {
            prepareGraphVC(gVC)
        }
    }
    
    @IBAction func showGraph(sender: UIButton) {
        program = brain.program
        if let gVC = splitViewController?.viewControllers.last?.contentViewController
                                                              as? GraphViewController{
            prepareGraphVC(gVC)
        } else {
            performSegueWithIdentifier(Storyboard.ShowGraph, sender: nil)
        }
    }
    
    private func prepareGraphVC(graphVC : GraphViewController){
        graphVC.navigationItem.title = brain.description
        graphVC.yForX = { [ weak weakSelf = self] x in
                     weakSelf?.brain.variableValues["M"] = x
                     return weakSelf?.brain.result.0
        }
    }
    
  // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
        
        if let savedProgram = program as? [AnyObject]{
            
            brain.program = savedProgram
            resultValue = brain.result
            if let gVC = splitViewController?.viewControllers.last?.contentViewController
                                                                as? GraphViewController {
                prepareGraphVC(gVC)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !brain.isPartialResult{
            
            program = brain.program
        }
    }

    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(splitViewController: UISplitViewController,
            collapseSecondaryViewController secondaryViewController: UIViewController,
                ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
    {
        if primaryViewController.contentViewController == self {
            if let gvc = secondaryViewController.contentViewController
                                               as? GraphViewController where gvc.yForX == nil {
                if program != nil {
                    return false
                }
                return true
            }
        }
        return false
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

