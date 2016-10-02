//
//  ViewController.swift
//  Calculator
//
//  Created by Tatiana Kornilova on 5/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var history: UILabel!
    @IBOutlet fileprivate weak var display: UILabel!
    
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
                display.text = formatter.string(from: NSNumber(value:value))
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            } else {
                display.text = "0"
                history.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    
    fileprivate var brain = CalculatorBrain()
    
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
}

