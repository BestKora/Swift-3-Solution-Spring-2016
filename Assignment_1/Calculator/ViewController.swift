//
//  ViewController.swift
//  Calculator
//
//  Created by Tatiana Kornilova on 5/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var history: UILabel!
    @IBOutlet fileprivate weak var display: UILabel!
    @IBOutlet weak var tochka: UIButton!{
        didSet {
            tochka.setTitle(decimalSeparator, for: UIControlState())
        }
    }
    
    fileprivate var userIsInTheMiddleOfTyping = false
    let decimalSeparator = formatter.decimalSeparator ?? "."
    
    @IBOutlet weak var stack0: UIStackView!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack2: UIStackView!
    @IBOutlet weak var stack3: UIStackView!
    @IBOutlet weak var stack4: UIStackView!
    @IBOutlet weak var stack5: UIStackView!
    @IBOutlet weak var stack6: UIStackView!
    
    @IBOutlet weak var sin_1: UIButton!
    @IBOutlet weak var cos_1: UIButton!
    @IBOutlet weak var tan_1: UIButton!
    @IBOutlet weak var x_2: UIButton!
    @IBOutlet weak var plusMinusButton: UIButton!
    
    @IBOutlet weak var rand: UIButton!
    
   private lazy var buttonBlank:UIButton = {
        let button = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        button.backgroundColor = UIColor.black
        button.setTitle("", for: UIControlState())
        return button
    }()

       
    @IBAction private func touchDigit(_ sender: UIButton) {
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
    
    private var displayValue: Double? {
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

    
   private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let value = displayValue{
                brain.setOperand(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        brain.clear()
        displayValue = nil
    }
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            display.text!.remove(at: display.text!.characters.index(before: display.text!.endIndex))
        }
        if display.text!.isEmpty {
            userIsInTheMiddleOfTyping  = false
            displayValue = brain.result
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
    
    // Код для тестирования "programs"
/*
    @IBAction private func save() {
        savedProgram = brain.program
    }
    
    @IBAction private func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
 */
    
    // Код для тестирования "programs"
    
    private var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func setM(_ sender: UIButton) {
        savedProgram = brain.program
    }
    
    @IBAction func pushM(_ sender: UIButton) {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection,
                     with coordinator:UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection,
                                              with: coordinator)
        configureView(newCollection.verticalSizeClass,buttonBlank:buttonBlank)
    }
    
    fileprivate func configureView(_ verticalSizeClass: UIUserInterfaceSizeClass, buttonBlank:UIButton) {
        if (verticalSizeClass == .compact)  {
            stack2.addArrangedSubview(plusMinusButton)
            stack3.addArrangedSubview(sin_1)
            stack4.addArrangedSubview(cos_1)
            stack5.addArrangedSubview(tan_1)
            stack6.addArrangedSubview(x_2)
            stack0.addArrangedSubview(buttonBlank)
            stack1.isHidden = true
        } else {
            stack1.isHidden = false
            stack1.addArrangedSubview(plusMinusButton)
            stack1.addArrangedSubview(sin_1)
            stack1.addArrangedSubview(cos_1)
            stack1.addArrangedSubview(tan_1)
            stack1.addArrangedSubview(x_2)
            stack0.removeArrangedSubview(buttonBlank)
        }
    }
}

