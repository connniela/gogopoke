//
//  UIColor+CommonColors.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/4.
//

import UIKit

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static let swablu100Color: UIColor = UIColor(hex: 0x7bcdff)
    
    static let swablu200Color: UIColor = UIColor(hex: 0x62ace6)
    
    static let swablu300Color: UIColor = UIColor(hex: 0x9c9cc5)
    
    static let swablu400Color: UIColor = UIColor(hex: 0x838394)
    
    static let swablu500Color: UIColor = UIColor(hex: 0x5a94cd)
    
    static let swablu600Color: UIColor = UIColor(hex: 0x396a83)
    
    static let swablu700Color: UIColor = UIColor(hex: 0x5a5a73)
    
    static let swablu800Color: UIColor = UIColor(hex: 0xcdcde6)
    
    static let swablu900Color: UIColor = UIColor(hex: 0xffffff)
    
    static let pikachu200Color: UIColor = UIColor(hex: 0xf6e652)
    
    static func getTypeColor(id: Int) -> UIColor {
        let typeColors: [UIColor] = [.clear,
                                     UIColor(hex: 0xA8A77A),
                                     UIColor(hex: 0xC22E28),
                                     UIColor(hex: 0xA98FF3),
                                     UIColor(hex: 0xA33EA1),
                                     UIColor(hex: 0xE2BF65),
                                     UIColor(hex: 0xB6A136),
                                     UIColor(hex: 0xA6B91A),
                                     UIColor(hex: 0x735797),
                                     UIColor(hex: 0xB7B7CE),
                                     UIColor(hex: 0xEE8130),
                                     UIColor(hex: 0x6390F0),
                                     UIColor(hex: 0x7AC74C),
                                     UIColor(hex: 0xF7D02C),
                                     UIColor(hex: 0xF95587),
                                     UIColor(hex: 0x96D9D6),
                                     UIColor(hex: 0x6F35FC),
                                     UIColor(hex: 0x705746),
                                     UIColor(hex: 0xD685AD)]
        if id < typeColors.count {
            return typeColors[id]
        }
        return .clear
    }
}
