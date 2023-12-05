//
//  UILabel+Shadow.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/5.
//

import UIKit

extension UILabel {
    
    func drawShaow(offset: CGSize = .init(width: 0, height: 2)) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.swablu700Color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
    }
}
