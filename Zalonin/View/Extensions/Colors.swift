//
//  Colors.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 31/03/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let goldenColor = UIColor(hexString : "b3a8a2")
    static let whiteColor = UIColor.white
    static let grayColor1 = UIColor(hexString : "585b67")
    static let grayColor2 = UIColor(hexString : "4e505b")
    static let grayColor3 = UIColor(hexString : "3e4048")
    static let blackColor = UIColor(hexString : "14161c")
    static let googleRedColor = UIColor(hexString : "db3236")
    static let facebookBlueColor = UIColor(hexString : "3B5998")
    static let clearColor = UIColor.clear
    static let placeholderColor = UIColor(displayP3Red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)
    
    static let startColor = UIColor(displayP3Red: 74/255, green: 75/255, blue: 86/255, alpha: 1)
    static let midColor = UIColor(displayP3Red: 41/255, green: 42/255, blue: 48/255, alpha: 1)
    static let greenColor = UIColor(displayP3Red: 79/255, green: 143/255, blue: 0, alpha: 1.0)
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
