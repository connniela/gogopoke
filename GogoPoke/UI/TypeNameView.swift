//
//  TypeNameView.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/5.
//

import UIKit
import SnapKit

class TypeNameView: UIView {
    
    private let label = UILabel()
    
    var typeInfo: TypeInfo? {
        didSet {
            if let typeInfo = typeInfo {
                label.text = typeInfo.typeNameText
                label.textColor = typeInfo.id == 0 ? .swablu700Color : .swablu900Color
                backgroundColor = UIColor.getTypeColor(id: typeInfo.id)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 2
        
        label.textColor = .swablu900Color
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.drawShaow()
        
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().inset(4)
            make.trailing.lessThanOrEqualToSuperview().inset(4)
            make.top.greaterThanOrEqualToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().inset(4)
            make.center.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(32)
        }
    }
}
