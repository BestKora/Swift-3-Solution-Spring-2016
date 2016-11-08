//
//  BallView.swift
//  Breakout
//
//  Copyright (c) 2015 private. All rights reserved.
//

import UIKit

class BallView: UIView {
    fileprivate struct Constants {
        static let backgroundColor = UIColor.white
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        setAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setAppearance (){
        self.backgroundColor = Constants.backgroundColor
        self.layer.cornerRadius = self.frame.width / 2
    }
}
