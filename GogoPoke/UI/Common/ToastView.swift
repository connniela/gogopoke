//
//  ToastView.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/5.
//

import UIKit
import SnapKit

class ToastView: UIView {
    
    let label = UILabel()
    
    var viewController: UIViewController?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        backgroundColor = .swablu700Color
        layer.cornerRadius = 18
        alpha = 0
        
        label.font = .systemFont(ofSize: 18)
        label.textColor = .swablu900Color
        label.numberOfLines = 0
        
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    static func makeToast(viewController: UIViewController, text: String) ->ToastView {
        let toastView = ToastView()
        toastView.viewController = viewController
        toastView.label.text = text
        return toastView
    }
    
    func show() {
        if let targetView = viewController?.view {
            targetView.addSubview(self)
            
            self.snp.makeConstraints { make in
                make.bottom.equalTo(targetView.safeAreaLayoutGuide.snp.bottom).inset(28)
                make.leading.greaterThanOrEqualToSuperview().inset(20)
                make.trailing.lessThanOrEqualToSuperview().inset(20)
                make.centerX.equalToSuperview()
            }
            
            UIView.animate(withDuration: 1) { [weak self] in
                self?.alpha = 1
            } completion: { finished in
                UIView.animate(withDuration: 2) { [weak self] in
                    self?.alpha = 0
                } completion: { [weak self] finished in
                    self?.removeFromSuperview()
                }
            }
        }
    }
}
