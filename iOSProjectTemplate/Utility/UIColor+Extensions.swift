//
//  UIColor+Extensions.swift
//  iOSProjectTemplate
//
//  Created by Michal Štembera on 19/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    /// Initialize color with rgb values in range 0...255
    convenience init(
        rgbWithRed red: Int,
        green: Int,
        blue: Int
    ) {
        assert(0...255 ~= red, "Invalid red component!")
        assert(0...255 ~= green, "Invalid green component!")
        assert(0...255 ~= blue, "Invalid blue component!")

        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }

    /// Initialize color with hex representation for example **FF00FF**
    /// - parameter hex: Hex value in format **AABBCC**
    convenience init(hex: Int) {
        let red = (hex >> 16) & 0xFF // Shifted by 2 bytes
        let green = (hex >> 8) & 0xFF // Shifted by 1 byte
        let blue = (hex >> 0) & 0xFF // Not shifted at all

        self.init(rgbWithRed: red, green: green, blue: blue)
    }

    /// Create 1x1 image with given color
    var image: UIImage? {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        self.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
