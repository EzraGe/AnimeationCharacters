//
//  Image.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/30.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithColor(_ color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    class func circularImageWithColor(_ color: UIColor, size : CGFloat) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()?.withRoundedCorners(radius: 0.5 * size)
        UIGraphicsEndImageContext()
        
        return image!
    }
}
