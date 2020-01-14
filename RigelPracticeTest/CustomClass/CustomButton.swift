//
//  CustomButton.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 11/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable

public class CustomButton:UIButton {
    
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    /// Sets the color of the border
    @IBInspectable public var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    /// Make the corners rounded with the specified radius
    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override public func prepareForInterfaceBuilder() {
    }
   
    
    
    
}
