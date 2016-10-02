//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Tatiana Kornilova on 5/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//
// Идея description заимствована https://github.com/m2mtech/calculator-2016

import Foundation

class CalculatorBrain{
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    
    private var error: String?
    
    var result: (Double, String?){
        get{
            return (accumulator, error)
        }
    }
    
    var variableValues = [String:Double]() {
        didSet {
            // если мы меняем "переменные", то перезапускаем program
            program = internalProgram
        }
    }

    private var currentPrecedence = Int.max
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }

    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    
    func setOperand(operand: Double) {
        accumulator = operand
        descriptionAccumulator = formatter.stringFromNumber(accumulator) ?? ""
        internalProgram.append(operand)
    }
    
    func setOperand(variable: String) {
        accumulator = variableValues[variable] ?? 0
        descriptionAccumulator = variable
        internalProgram.append(variable)
    }

     private var operations : [String: Operation] = [
        "rand": Operation.NullaryOperation(drand48, "rand()"),
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "±": Operation.UnaryOperation({ -$0 }, { "±(" + $0 + ")"},nil),
        
        "√": Operation.UnaryOperation(sqrt, { "√(" + $0 + ")"},
                                                 { $0 < 0 ? "√ отриц. числа" : nil }),
        
        "cos": Operation.UnaryOperation(cos,{ "cos(" + $0 + ")"}, nil),
        "sin": Operation.UnaryOperation(sin,{ "sin(" + $0 + ")"}, nil),
        "tan": Operation.UnaryOperation(tan,{ "tan(" + $0 + ")"}, nil ),
        
        "sin⁻¹" : Operation.UnaryOperation(asin,{ "sin⁻¹(" + $0 + ")"},
                            { $0 < -1.0 || $0 > 1.0 ? "не в диапазоне [-1,1]" : nil }),
        "cos⁻¹" : Operation.UnaryOperation(acos, { "cos⁻¹(" + $0 + ")"},
                            { $0 < -1.0 || $0 > 1.0 ? "не в диапазоне [-1,1]" : nil }),
        
        "tan⁻¹" : Operation.UnaryOperation(atan, { "tan⁻¹(" + $0 + ")"}, nil),
        
        "ln" : Operation.UnaryOperation(log, { "ln(" + $0 + ")"},
                                                { $0 < 0 ? "ln отриц. числа" : nil }),
        "x⁻¹" : Operation.UnaryOperation({1.0/$0}, {"(" + $0 + ")⁻¹"},
                                             { $0 == 0.0 ? "Деление на ноль" : nil }),
        
        "х²" : Operation.UnaryOperation({$0 * $0}, { "(" + $0 + ")²"}, nil),
        "×": Operation.BinaryOperation(*, { $0 + " × " + $1 }, 1, nil),
        
        "÷": Operation.BinaryOperation(/, { $0 + " ÷ " + $1 }, 1,
                                             { $1 == 0.0 ? "Деление на ноль" : nil }),
        
        "+": Operation.BinaryOperation(+, { $0 + " + " + $1 }, 0, nil),
        "−": Operation.BinaryOperation(-, { $0 + " - " + $1 }, 0, nil),
        "xʸ": Operation.BinaryOperation(pow,{ $0 + " ^ " + $1 }, 2, nil),
        "=": Operation.Equals
    ]

    private enum Operation{
        case NullaryOperation(() -> Double,String)
        case Constant(Double)
        case UnaryOperation((Double) -> Double,(String) -> String, (Double -> String?)?)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int,
                                                                   ((Double, Double) -> String?)?)
        case Equals
        
    }
    
    func performOperation(symbol: String){
        internalProgram.append(symbol)
        if let operation = operations[symbol]{
            switch operation {
            case .NullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction, let validator):
                error = validator?(accumulator)
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let precedence, let validator):
                executeBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryOperation: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator, validator: validator)
            case .Equals:
                executeBinaryOperation()
            
            }
        }
    }
    
    private func executeBinaryOperation(){
        if pending != nil{
            error = pending!.validator?(pending!.firstOperand, accumulator)
            accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand,
                                                                  descriptionAccumulator)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let symbol = op as? String {
                        if operations[symbol] != nil {
                             // symbol - это операция
                            performOperation(symbol)
                        } else {
                            // symbol - это переменная
                            setOperand(symbol)
                        }

                    }
                }
            }
        }
    }
    
    func undoLast() {
        guard !internalProgram.isEmpty  else { clear (); return }
        internalProgram.removeLast()
        program = internalProgram
    }
    
   func clear() {
        accumulator = 0.0
        pending = nil
        descriptionAccumulator = " "
        currentPrecedence = Int.max
        internalProgram.removeAll(keepCapacity: false)
    }
    
    func clearVariables() {
        variableValues = [:]
    }

    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) ->Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        var validator: ((Double, Double) -> String?)?
    }
}

let formatter:NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    formatter.maximumFractionDigits = 6
    formatter.groupingSeparator = " "
    formatter.locale = NSLocale.currentLocale()
    return formatter

} ()
