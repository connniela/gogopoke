//
//  SegmentedControl.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/5.
//

import UIKit

class SegmentedControl: UISegmentedControl {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        initializeStyling()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeStyling()
    }
    
    private func initializeStyling() {
        tintColor = .swablu300Color
        selectedSegmentTintColor = .swablu800Color
        setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.swablu700Color], for: .selected)
        setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.swablu800Color], for: .normal)
    }
}
