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
    @IBOutlet fileprivate weak var display: UILabel!
    
    @IBOutlet weak var graph: UIButton!{
        didSet{
            graph.isEnabled = false
        }
    }
    fileprivate struct Storyboard{
        static let ShowGraph = "Show Graph"
    }
    
    fileprivate var userIsInTheMiddleOfTyping = false
    let decimalSeparator = formatter.decimalSeparator ?? "."
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
//----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit !=  decimalSeparator) && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
//--------------------------------------------------

            if (digit != decimalSeparator) || (textCurrentlyInDisplay.range(of: decimalSeparator) == nil) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    fileprivate var resultValue: (Double, String?) = (0.0, nil) {
        didSet {
            graph.isEnabled = !brain.isPartialResult
            switch resultValue {
            case (_, nil) : displayValue = resultValue.0
            case (_, let error):
                display.text = error
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    fileprivate var displayValue: Double? {
        get {
            if let text = display.text,
                let value = formatter.number(from: text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.string(from: value as NSNumber)
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            } else {
                display.text = "0"
                history.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    fileprivate var brain = CalculatorBrain()
    
    fileprivate let defaults = UserDefaults.standard
    fileprivate struct Keys {
        static let Program = "CalculatorViewController.Program"
    }
    
    typealias PropertyList = AnyObject
    
    fileprivate var program: PropertyList? {
        get { return defaults.object(forKey: Keys.Program) as CalculatorViewController.PropertyList? }
        set { defaults.set(newValue, forKey: Keys.Program) }
    }
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
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
    
    @IBAction func clearAll(_ sender: UIButton) {
        brain.clearVariables()
        brain.clear()
        displayValue = nil
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            display.text!.remove(at: display.text!.characters.index(before: display.text!.endIndex))
            if display.text!.isEmpty {
                userIsInTheMiddleOfTyping  = false
                resultValue = brain.result
            }
        } else {
            brain.undoLast()
            resultValue = brain.result
        }
    }
    
    @IBAction func plusMinus(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            if (display.text!.range(of: "-") != nil) {
                display.text = String((display.text!).characters.dropFirst())
            } else {
                display.text = "-" + display.text!
            }
        } else {
            performOperation(sender)
        }
    }
    
    @IBAction func setM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        if let value = displayValue {
            brain.variableValues[symbol] = value
            resultValue = brain.result
        }
    }
    
    
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(sender.currentTitle!)
        resultValue = brain.result
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String,
                                                   sender: Any?) -> Bool {
        return !brain.isPartialResult
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gVC = segue.destination.contentViewController
                                                           as? GraphViewController, segue.identifier == Storyboard.ShowGraph {
            prepareGraphVC(gVC)
        }
    }
    
    @IBAction func showGraph(_ sender: UIButton) {
        program = brain.program
        if let gVC = splitViewController?.viewControllers.last?.contentViewController
                                                              as? GraphViewController{
            prepareGraphVC(gVC)
        } else {
            performSegue(withIdentifier: Storyboard.ShowGraph, sender: nil)
        }
    }
    
    fileprivate func prepareGraphVC(_ graphVC : GraphViewController){
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
            
            brain.program = savedProgram as CalculatorBrain.PropertyList
            resultValue = brain.result
            if let gVC = splitViewController?.viewControllers.last?.contentViewController
                                                                as? GraphViewController {
                prepareGraphVC(gVC)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !brain.isPartialResult{
            
            program = brain.program
        }
    }

    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController,
            collapseSecondary secondaryViewController: UIViewController,
                onto primaryViewController: UIViewController) -> Bool
    {
        if primaryViewController.contentViewController == self {
            if let gvc = secondaryViewController.contentViewController
                                               as? GraphViewController, gvc.yForX == nil {
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

