//
//  Extensions.swift
//  Breakout
//
//  Copyright (c) 2015 private. All rights reserved.
//

import Foundation

extension String {
    func `repeat`(_ n:Int) -> String {
        if n <= 0 { return "" }
        
        var result = self
        for _ in 1 ..< n { result += self }
        return result
    }
}

