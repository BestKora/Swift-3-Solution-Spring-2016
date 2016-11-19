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
    
    var result: Double{
        get{
            return accumulator
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
    
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionAccumulator = formatter.string(from: NSNumber(value:accumulator)) ?? ""
        internalProgram.append(operand as AnyObject)
    }
    
    private var operations : [String: Operation] = [
        "rand": Operation.nullaryOperation(drand48, "rand()"),
        "π": Operation.constant(M_PI),
        "e": Operation.constant(M_E),
        "±": Operation.unaryOperation({ -$0 }, { "±(" + $0 + ")"}),
        "√": Operation.unaryOperation(sqrt, { "√(" + $0 + ")"}),
        "cos": Operation.unaryOperation(cos,{ "cos(" + $0 + ")"}),
        "sin": Operation.unaryOperation(sin,{ "sin(" + $0 + ")"}),
        "tan": Operation.unaryOperation(tan,{ "tan(" + $0 + ")"}),
        "sin⁻¹" : Operation.unaryOperation(asin, { "sin⁻¹(" + $0 + ")"}),
        "cos⁻¹" : Operation.unaryOperation(acos, { "cos⁻¹(" + $0 + ")"}),
        "tan⁻¹" : Operation.unaryOperation(atan, { "tan⁻¹(" + $0 + ")"}),
        "ln" : Operation.unaryOperation(log, { "ln(" + $0 + ")"}),
        "x⁻¹" : Operation.unaryOperation({1.0/$0}, {"(" + $0 + ")⁻¹"}),
        "х²" : Operation.unaryOperation({$0 * $0}, { "(" + $0 + ")²"}),
        "×": Operation.binaryOperation(*, { $0 + " × " + $1 }, 1),
        "÷": Operation.binaryOperation(/, { $0 + " ÷ " + $1 }, 1),
        "+": Operation.binaryOperation(+, { $0 + " + " + $1 }, 0),
        "−": Operation.binaryOperation(-, { $0 + " - " + $1 }, 0),
        "xʸ" : Operation.binaryOperation(pow, { $0 + " ^ " + $1 }, 2),
        "=": Operation.equals
        
    ]
    
    private enum Operation{
        case nullaryOperation(() -> Double,String)
        case constant(Double)
        case unaryOperation((Double) -> Double,(String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
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
            case .unaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .binaryOperation(let function, let descriptionFunction, let precedence):
                executeBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryOperation: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .equals:
                executeBinaryOperation()
            
            }
        }
    }
    
    private func executeBinaryOperation(){
        
        if pending != nil{
            accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
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
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
   func clear() {
        accumulator = 0.0
        pending = nil
        descriptionAccumulator = " "
        currentPrecedence = Int.max
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) ->Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
}

let formatter:NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    formatter.notANumberSymbol = "Error"
    formatter.groupingSeparator = " "
    formatter.locale = Locale.current
    return formatter

} ()
