//
//  LoadingView.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/5.
//

import UIKit

class LoadingView: UIActivityIndicatorView {
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: .large)
        initializeStyling()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeStyling()
    }
    
    private func initializeStyling() {
        hidesWhenStopped = true
        color = .swablu700Color
    }
}
