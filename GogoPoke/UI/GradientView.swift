//
//  GradientView.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/5.
//

import UIKit

class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradient: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    var firstColor: UIColor? {
        didSet {
            colorsDidChange()
        }
    }
    
    var secondColor: UIColor? {
        didSet {
            colorsDidChange()
        }
    }
    
    private func colorsDidChange() {
        guard let firstColor = firstColor else { return }
        
        if let secondColor = secondColor {
            gradient.colors = [firstColor.cgColor, secondColor.cgColor]
        }
        else {
            gradient.colors = [firstColor.cgColor, firstColor.cgColor]
        }
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
}
