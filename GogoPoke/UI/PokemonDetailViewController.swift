//
//  PokemonDetailViewController.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/2.
//

import Foundation
import SnapKit

class PokemonDetailViewController: UIViewController {
    
    private let viewModel = PokemonDetailViewModel()
    
    private let ownButton = UIButton()
    private let defaultImageView = ImageCacheView()
    private let maleButton = UIButton()
    private let femaleButton = UIButton()
    private let nameLabel = UILabel()
    private let typeStack = UIStackView()
    private let bodyLabel = UILabel()
    private let statStack = UIStackView()
    private let evolutionStack = UIStackView()
    private let flavorLabel = UILabel()
    private let gradient = CAGradientLayer()
    
    private var isMale: Bool = true
    
    private var evolutionChainViews: [PokemonEvolutionChain] = []
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(pokemonInfo: PokemonInfo) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        viewModel.pokemonInfo = pokemonInfo
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        
        let container = UIView()
        container.backgroundColor = .swablu400Color
        container.layer.cornerRadius = 16
        container.layer.shadowOffset = .init(width: 0, height: 0)
        container.layer.shadowColor = UIColor.swablu700Color.cgColor
        container.layer.shadowOpacity = 1
        
        view.addSubview(container)
        
        container.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        }
        
        let scrollView = UIScrollView()
        
        container.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        
        scrollView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().offset(-72)
            make.width.equalToSuperview().offset(-48)
        }
        
        ownButton.setImage(UIImage(named: "unowned"), for: .normal)
        ownButton.setImage(UIImage(named: "owned"), for: .selected)
        ownButton.addTarget(self, action: #selector(ownButtonTapped), for: .touchUpInside)
        ownButton.isEnabled = false
        
        container.addSubview(ownButton)
        
        ownButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.size.equalTo(48)
        }
        
        let closeBg = GradientView()
        closeBg.firstColor = .swablu700Color.withAlphaComponent(0)
        closeBg.secondColor = .swablu700Color
        closeBg.gradient.cornerRadius = 16
        closeBg.gradient.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        container.addSubview(closeBg)
        
        closeBg.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(72)
        }
        
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.layer.cornerRadius = 20
        closeButton.backgroundColor = .swablu700Color
        closeButton.layer.shadowOffset = .init(width: 0, height: 0)
        closeButton.layer.shadowColor = UIColor.swablu700Color.cgColor
        closeButton.layer.shadowOpacity = 1
        
        container.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(40)
        }
        
        loadStackView(stackView)
    }
    
    private func loadStackView(_ stackView: UIStackView) {
        defaultImageView.backgroundColor = .swablu800Color.withAlphaComponent(0.5)
        defaultImageView.layer.cornerRadius = 60
        defaultImageView.layer.shadowOffset = .init(width: 0, height: 0)
        defaultImageView.layer.shadowColor = UIColor.swablu700Color.cgColor
        defaultImageView.layer.shadowOpacity = 1
        
        nameLabel.textColor = .swablu900Color
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.drawShaow()
        nameLabel.accessibilityIdentifier = "pokemonName"
        
        typeStack.axis = .horizontal
        typeStack.spacing = 4
        typeStack.alignment = .fill
        
        bodyLabel.textColor = .swablu900Color
        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        
        flavorLabel.textColor = .swablu800Color
        flavorLabel.font = .systemFont(ofSize: 14)
        flavorLabel.numberOfLines = 0
        flavorLabel.textAlignment = .center
        
        stackView.addArrangedSubview(defaultImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(typeStack)
        stackView.addArrangedSubview(bodyLabel)
        stackView.addArrangedSubview(flavorLabel)
        stackView.setCustomSpacing(14, after: defaultImageView)
        stackView.setCustomSpacing(16, after: flavorLabel)
        
        defaultImageView.snp.makeConstraints { make in
            make.size.equalTo(120)
        }
        
        flavorLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        maleButton.setImage(UIImage(named: "male"), for: .normal)
        maleButton.addTarget(self, action: #selector(maleButtonTapped), for: .touchUpInside)
        maleButton.layer.borderWidth = 2
        maleButton.layer.borderColor = UIColor.pikachu200Color.cgColor
        maleButton.layer.cornerRadius = 12
        
        femaleButton.setImage(UIImage(named: "female"), for: .normal)
        femaleButton.addTarget(self, action: #selector(femaleButtonTapped), for: .touchUpInside)
        femaleButton.layer.borderColor = UIColor.pikachu200Color.cgColor
        femaleButton.layer.cornerRadius = 12
        femaleButton.isHidden = true
        
        stackView.addSubview(maleButton)
        stackView.addSubview(femaleButton)
        
        maleButton.snp.makeConstraints { make in
            make.leading.equalTo(defaultImageView.snp.trailing).offset(8)
            make.bottom.equalTo(defaultImageView)
            make.size.equalTo(24)
        }
        
        femaleButton.snp.makeConstraints { make in
            make.leading.equalTo(maleButton.snp.trailing).offset(8)
            make.bottom.equalTo(defaultImageView)
            make.size.equalTo(24)
        }
        
        let line1 = UIView()
        line1.backgroundColor = .swablu900Color.withAlphaComponent(0.5)
        stackView.addArrangedSubview(line1)
        line1.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalToSuperview().offset(-24)
        }
        
        let statLabel = UILabel()
        statLabel.textColor = .swablu900Color
        statLabel.font = .systemFont(ofSize: 16)
        statLabel.text = "Base Stats"
        
        stackView.addArrangedSubview(statLabel)
        
        statStack.axis = .vertical
        statStack.spacing = 8
        statStack.alignment = .fill
        
        stackView.addArrangedSubview(statStack)
        stackView.setCustomSpacing(16, after: statStack)
        
        let line2 = UIView()
        line2.backgroundColor = .swablu900Color.withAlphaComponent(0.5)
        stackView.addArrangedSubview(line2)
        line2.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalToSuperview().offset(-24)
        }
        
        let evolutionLabel = UILabel()
        evolutionLabel.textColor = .swablu900Color
        evolutionLabel.font = .systemFont(ofSize: 16)
        evolutionLabel.text = "Evolution"
        
        stackView.addArrangedSubview(evolutionLabel)
        
        evolutionStack.axis = .horizontal
        evolutionStack.spacing = 8
        evolutionStack.alignment = .center
        
        stackView.addArrangedSubview(evolutionStack)
        
        evolutionStack.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GogoLogger.logger.info("🍄Open Pokémon detail")
        
        viewModel.delegate = self
        loadPokemon()
    }
}

// MARK: Actions
extension PokemonDetailViewController {
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func ownButtonTapped() {
        if let pokemonInfo = viewModel.pokemonInfo {
            if viewModel.isMyPokemon {
                PokeManager.removeMyPokemonId(pokemonInfo: pokemonInfo)
                ToastView.makeToast(viewController: self, text: "Removed from my Pokémon.").show()
            }
            else {
                PokeManager.addMyPokemonId(pokemonInfo: pokemonInfo)
                ToastView.makeToast(viewController: self, text: "Added to my Pokémon.").show()
            }
            viewModel.isMyPokemon = !viewModel.isMyPokemon
            updateOwnButton()
        }
    }
    
    @objc private func maleButtonTapped() {
        if isMale {
            return
        }
        isMale = !isMale
        updateGenderButton()
    }
    
    @objc private func femaleButtonTapped() {
        if !isMale {
            return
        }
        isMale = !isMale
        updateGenderButton()
    }
    
    @objc private func chainViewTapped(_ sender: Any) {
        if let chainView = sender as? PokemonEvolutionChain {
            if chainView.pokemonInfo?.id == viewModel.pokemonInfo?.id {
                return
            }
            
            if let pokemonInfo = chainView.pokemonInfo {
                viewModel.fetchPokemon(id: pokemonInfo.id)
            }
        }
    }
}

// MARK: Privates
extension PokemonDetailViewController {
    
    private func loadPokemon() {
        updatePokemonInfo()
        
        if let pokemonInfo = viewModel.pokemonInfo {
            viewModel.fetchPokemon(id: pokemonInfo.id)
        }
    }
    
    private func updatePokemonInfo() {
        if let pokemonInfo = viewModel.pokemonInfo {
            isMale = true
            updateGenderButton()
            if pokemonInfo.frontFemale != nil {
                femaleButton.isHidden = false
            }
            else {
                femaleButton.isHidden = true
            }
            nameLabel.text = String(format: "#%04d %@", pokemonInfo.id, pokemonInfo.pokemonNameText)
            typeStack.subviews.forEach { $0.removeFromSuperview() }
            for type in pokemonInfo.types {
                let typeNameView = TypeNameView()
                typeNameView.typeInfo = type
                typeStack.addArrangedSubview(typeNameView)
            }
            bodyLabel.text = "Weight: \(pokemonInfo.weight ?? 0)kg  Height: \(pokemonInfo.height ?? 0)m"
            updateOwnButton()
        }
    }
    
    private func updateGenderButton() {
        if isMale {
            defaultImageView.setImage(string: viewModel.pokemonInfo?.frontDefault)
            maleButton.layer.borderWidth = 2
            femaleButton.layer.borderWidth = 0
        }
        else {
            defaultImageView.setImage(string: viewModel.pokemonInfo?.frontFemale)
            maleButton.layer.borderWidth = 0
            femaleButton.layer.borderWidth = 2
        }
    }
    
    private func updateOwnButton() {
        ownButton.isSelected = viewModel.isMyPokemon
        ownButton.isEnabled = true
    }
}

// MARK: PokemonDetailViewModelDelegate
extension PokemonDetailViewController: PokemonDetailViewModelDelegate {
    
    func pokemonDetailViewModelDidLoadPokemon() {
        updatePokemonInfo()
        
        if viewModel.clainLink != nil {
            for chainView in evolutionChainViews {
                chainView.isHighlight = chainView.pokemonInfo?.id == viewModel.pokemonInfo?.id
            }
        }
    }
    
    func pokemonDetailViewModelDidLoadPokemonWithError() {
        ToastView.makeToast(viewController: self, text: "Something went wrong. Please check your internet connection and try again!").show()
    }
    
    func pokemonDetailViewModelDidInitEvolutionChain(count: Int) {
        evolutionStack.subviews.forEach { $0.removeFromSuperview() }
        evolutionChainViews.removeAll()
        
        for i in 0..<count {
            let chainView = PokemonEvolutionChain()
            evolutionStack.addArrangedSubview(chainView)
            evolutionChainViews.append(chainView)
            
            if i < count - 1 {
                let arrow = UIImageView(image: UIImage(named: "forward")?.withRenderingMode(.alwaysTemplate))
                arrow.tintColor = .white
                arrow.contentMode = .scaleAspectFit
                evolutionStack.addArrangedSubview(arrow)
                arrow.snp.makeConstraints { make in
                    make.size.equalTo(24)
                }
            }
        }
    }
    
    func pokemonDetailViewModelDidLoadEvolutionChain(pokemonInfo: PokemonInfo, index: Int) {
        let chainView = evolutionChainViews[index]
        chainView.pokemonInfo = pokemonInfo
        chainView.isHighlight = pokemonInfo.id == viewModel.pokemonInfo?.id
        chainView.addTarget(self, action: #selector(chainViewTapped(_:)), for: .touchUpInside)
    }
    
    func pokemonDetailViewModelDidLoadPokemonStats(stats: [StatInfo]) {
        statStack.subviews.forEach { $0.removeFromSuperview() }
        
        for stat in stats {
            let nameLabel = UILabel()
            nameLabel.textAlignment = .right
            nameLabel.textColor = .swablu800Color
            nameLabel.font = .systemFont(ofSize: 14)
            
            let statLabel = UILabel()
            statLabel.textColor = .swablu900Color
            statLabel.font = .systemFont(ofSize: 14)
            
            let hStack = UIStackView(arrangedSubviews: [nameLabel, statLabel])
            hStack.axis = .horizontal
            hStack.spacing = 8
            hStack.alignment = .center
            hStack.distribution = .fillEqually
            
            statStack.addArrangedSubview(hStack)
            
            nameLabel.text = stat.statNameText
            statLabel.text = "\(stat.baseStat ?? 0)"
        }
    }
    
    func pokemonDetailViewModelDidLoadFlavorText(text: String?) {
        flavorLabel.text = text
    }
}

fileprivate class PokemonEvolutionChain: UIButton {
    
    private let pokemonImageView = ImageCacheView()
    
    var pokemonInfo: PokemonInfo? {
        didSet {
            if let pokemonInfo = pokemonInfo {
                pokemonImageView.setImage(string: pokemonInfo.frontDefault)
            }
        }
    }
    
    var isHighlight: Bool = false {
        didSet {
            if isHighlight {
                pokemonImageView.layer.borderWidth = 2
            }
            else {
                pokemonImageView.layer.borderWidth = 0
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pokemonImageView.backgroundColor = .swablu800Color.withAlphaComponent(0.5)
        pokemonImageView.layer.cornerRadius = 30
        pokemonImageView.layer.borderColor = UIColor.pikachu200Color.cgColor
        pokemonImageView.isUserInteractionEnabled = false
        addSubview(pokemonImageView)
        pokemonImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.size.equalTo(60)
        }
    }
}
