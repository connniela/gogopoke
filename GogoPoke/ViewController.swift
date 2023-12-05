//
//  ViewController.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/2.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func loadView() {
        super.loadView()
        view.backgroundColor = .swablu300Color
        
        let imageView = UIImageView(image: UIImage(named: "pokemon_PNG146"))
        imageView.alpha = 0.5
        imageView.contentMode = .scaleAspectFill
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        
        let gogoPokeLabel = UILabel()
        gogoPokeLabel.textColor = .swablu900Color.withAlphaComponent(0.5)
        gogoPokeLabel.font = .boldSystemFont(ofSize: 24)
        gogoPokeLabel.textAlignment = .center
        gogoPokeLabel.text = "Gogo Poke"
        
        let pokemonListButton = MainButton()
        pokemonListButton.setTitle("Pokémon List", for: .normal)
        pokemonListButton.addTarget(self, action: #selector(pokemonListButtonTapped), for: .touchUpInside)
        pokemonListButton.accessibilityIdentifier = "pokemonListButton"
        
        let typeChartButton = MainButton()
        typeChartButton.setTitle("Type Chart", for: .normal)
        typeChartButton.addTarget(self, action: #selector(typeChartButtonTapped), for: .touchUpInside)
        typeChartButton.accessibilityIdentifier = "typeChartButton"
        
        let typePokemonButton = MainButton()
        typePokemonButton.setTitle("Type Pokémon", for: .normal)
        typePokemonButton.addTarget(self, action: #selector(typePokemonButtonTapped), for: .touchUpInside)
        typePokemonButton.accessibilityIdentifier = "typePokemonButton"
        
        let stackView = UIStackView(arrangedSubviews: [gogoPokeLabel, pokemonListButton, typeChartButton, typePokemonButton])
        stackView.axis = .vertical
        stackView.spacing = 60
        stackView.alignment = .center
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).inset(24)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: Actions
extension ViewController {
    
    @objc private func pokemonListButtonTapped() {
        let vc = PokemonListViewController()
        present(vc, animated: true)
    }
    
    @objc private func typeChartButtonTapped() {
        let vc = TypeChartViewController()
        present(vc, animated: true)
    }
    
    @objc private func typePokemonButtonTapped() {
        let vc = TypePokemonViewController()
        present(vc, animated: true)
    }
}

fileprivate class MainButton: UIButton {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .swablu700Color
        layer.cornerRadius = 8
        layer.shadowOffset = .init(width: 0, height: 4)
        layer.shadowColor = UIColor.swablu700Color.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
        
        snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(200)
        }
    }
}

