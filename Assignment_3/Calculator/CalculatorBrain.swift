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
    
    fileprivate var accumulator = 0.0
    fileprivate var internalProgram = [AnyObject]()
    
    fileprivate var error: String?
    
    var result: (Double, String?){
        get{
            return (accumulator, error)
        }
    }
    
    var variableValues = [String:Double]() {
        didSet {
            // если мы меняем "переменные", то перезапускаем program
            program = internalProgram as CalculatorBrain.PropertyList
        }
    }

    fileprivate var currentPrecedence = Int.max
    fileprivate var descriptionAccumulator = "0" {
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
    
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionAccumulator = formatter.string(from: NSNumber(value: accumulator)) ?? ""
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(_ variable: String) {
        accumulator = variableValues[variable] ?? 0
        descriptionAccumulator = variable
        internalProgram.append(variable as AnyObject)
    }

     fileprivate var operations : [String: Operation] = [
        "rand": Operation.nullaryOperation(drand48, "rand()"),
        "π": Operation.constant(M_PI),
        "e": Operation.constant(M_E),
        "±": Operation.unaryOperation({ -$0 }, { "±(" + $0 + ")"},nil),
        
        "√": Operation.unaryOperation(sqrt, { "√(" + $0 + ")"},
                                                 { $0 < 0 ? "√ отриц. числа" : nil }),
        
        "cos": Operation.unaryOperation(cos,{ "cos(" + $0 + ")"}, nil),
        "sin": Operation.unaryOperation(sin,{ "sin(" + $0 + ")"}, nil),
        "tan": Operation.unaryOperation(tan,{ "tan(" + $0 + ")"}, nil ),
        
        "sin⁻¹" : Operation.unaryOperation(asin,{ "sin⁻¹(" + $0 + ")"},
                            { $0 < -1.0 || $0 > 1.0 ? "не в диапазоне [-1,1]" : nil }),
        "cos⁻¹" : Operation.unaryOperation(acos, { "cos⁻¹(" + $0 + ")"},
                            { $0 < -1.0 || $0 > 1.0 ? "не в диапазоне [-1,1]" : nil }),
        
        "tan⁻¹" : Operation.unaryOperation(atan, { "tan⁻¹(" + $0 + ")"}, nil),
        
        "ln" : Operation.unaryOperation(log, { "ln(" + $0 + ")"},
                                                { $0 < 0 ? "ln отриц. числа" : nil }),
        "x⁻¹" : Operation.unaryOperation({1.0/$0}, {"(" + $0 + ")⁻¹"},
                                             { $0 == 0.0 ? "Деление на ноль" : nil }),
        
        "х²" : Operation.unaryOperation({$0 * $0}, { "(" + $0 + ")²"}, nil),
        "×": Operation.binaryOperation(*, { $0 + " × " + $1 }, 1, nil),
        
        "÷": Operation.binaryOperation(/, { $0 + " ÷ " + $1 }, 1,
                                             { $1 == 0.0 ? "Деление на ноль" : nil }),
        
        "+": Operation.binaryOperation(+, { $0 + " + " + $1 }, 0, nil),
        "−": Operation.binaryOperation(-, { $0 + " - " + $1 }, 0, nil),
        "xʸ": Operation.binaryOperation(pow,{ $0 + " ^ " + $1 }, 2, nil),
        "=": Operation.equals
    ]

    fileprivate enum Operation{
        case nullaryOperation(() -> Double,String)
        case constant(Double)
        case unaryOperation((Double) -> Double,(String) -> String, ((Double) -> String?)?)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String, Int,
                                                                   ((Double, Double) -> String?)?)
        case equals
        
    }
    
    func performOperation(_ symbol: String){
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol]{
            switch operation {
            case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .unaryOperation(let function, let descriptionFunction, let validator):
                error = validator?(accumulator)
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .binaryOperation(let function, let descriptionFunction, let precedence, let validator):
                executeBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryOperation: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator, validator: validator)
            case .equals:
                executeBinaryOperation()
            
            }
        }
    }
    
    fileprivate func executeBinaryOperation(){
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
            return internalProgram as CalculatorBrain.PropertyList
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
        program = internalProgram as CalculatorBrain.PropertyList
    }
    
   func clear() {
        accumulator = 0.0
        pending = nil
        descriptionAccumulator = " "
        currentPrecedence = Int.max
        internalProgram.removeAll(keepingCapacity: false)
    }
    
    func clearVariables() {
        variableValues = [:]
    }

    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) ->Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        var validator: ((Double, Double) -> String?)?
    }
}

let formatter:NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    formatter.groupingSeparator = " "
    formatter.locale = Locale.current
    return formatter

} ()
