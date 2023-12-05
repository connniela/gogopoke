//
//  PokemonListCell.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/4.
//

import UIKit
import SnapKit

class PokemonListCell: UICollectionViewCell {
    static let identifier = "PokemonListCell"
    static let listHeight = CGFloat(72)
    static let gridHeight = CGFloat(136)
    static let gridWidth = CGFloat(90)
    
    private let imageView = ImageCacheView()
    private let stackView = UIStackView()
    private let nameLabel = UILabel()
    private let infoLabel = UILabel()
    
    var pokemonInfo: PokemonInfo? {
        didSet {
            if let pokemonInfo = pokemonInfo {
                nameLabel.text = pokemonInfo.pokemonNameText
                infoLabel.text = String(format: "#%04d / %@", pokemonInfo.id, pokemonInfo.typeNameText)
                imageView.setImage(string: pokemonInfo.frontDefault)
            }
        }
    }
    
    var isGridLayout: Bool = false {
        didSet {
            if oldValue == isGridLayout {
                return
            }
            
            if isGridLayout {
                stackView.alignment = .center
                
                imageView.snp.remakeConstraints { make in
                    make.top.equalToSuperview().inset(6)
                    make.centerX.equalToSuperview()
                    make.size.equalTo(60)
                }
                
                stackView.snp.remakeConstraints { make in
                    make.top.equalTo(imageView.snp.bottom).offset(8)
                    make.centerX.equalToSuperview()
                    make.leading.greaterThanOrEqualToSuperview()
                    make.trailing.lessThanOrEqualToSuperview()
                }
            }
            else {
                stackView.alignment = .leading
                
                imageView.snp.remakeConstraints { make in
                    make.centerY.leading.equalToSuperview()
                    make.size.equalTo(60)
                }
                
                stackView.snp.remakeConstraints { make in
                    make.centerY.equalTo(imageView)
                    make.leading.equalTo(imageView.snp.trailing).offset(12)
                    make.trailing.lessThanOrEqualToSuperview()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundView = nil
        backgroundColor = .clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .swablu800Color.withAlphaComponent(0.5)
        imageView.layer.cornerRadius = 30
        
        nameLabel.textColor = .swablu900Color
        nameLabel.font = .boldSystemFont(ofSize: 14)
        
        infoLabel.textColor = .swablu700Color
        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(infoLabel)
        
        addSubview(imageView)
        addSubview(stackView)
        
        imageView.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(60)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancelImageLoad()
        imageView.image = nil
    }
}
