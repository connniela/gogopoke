//
//  TypePokemonViewController.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/5.
//

import UIKit
import SnapKit

class TypePokemonViewController: UIViewController {
    
    private let viewModel = TypePokemonViewModel()
    
    private let titleLabel = UILabel()
    private let pickerView = UIPickerView()
    private var collectionView: UICollectionView!
    private let loadingView = LoadingView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .swablu900Color
        
        let topBarBg = UIView()
        topBarBg.backgroundColor = .swablu700Color
        topBarBg.layer.shadowOffset = .init(width: 0, height: 2)
        topBarBg.layer.shadowColor = UIColor.swablu700Color.cgColor
        topBarBg.layer.shadowOpacity = 1
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleLabel.textColor = .swablu900Color
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.accessibilityIdentifier = "typeTitleLabel"
        
        let topBar = UIView()
        
        topBar.addSubview(titleLabel)
        topBar.addSubview(backButton)
        
        view.addSubview(topBarBg)
        view.addSubview(topBar)
        
        topBarBg.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.leading.trailing.equalTo(topBar)
        }
        
        topBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(48)
            make.leading.equalToSuperview().inset(16)
        }
        
        let typeLabel = UILabel()
        typeLabel.text = "Type"
        typeLabel.textColor = .swablu700Color
        typeLabel.font = .systemFont(ofSize: 10)
        typeLabel.textAlignment = .center
        
        view.addSubview(typeLabel)
        
        typeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
            make.height.equalTo(28)
        }
        
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(typeLabel.snp.bottom)
            make.height.equalTo(100)
        }
        
        let line = UIView()
        line.backgroundColor = .swablu600Color
        
        view.addSubview(line)
        
        line.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(pickerView.snp.bottom)
            make.height.equalTo(1)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.top.equalTo(collectionView).offset(24)
            make.centerX.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GogoLogger.logger.info("⚡Open type pokemon")
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        collectionView.register(PokemonListCell.self, forCellWithReuseIdentifier: PokemonListCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadingView.startAnimating()
        
        viewModel.delegate = self
        viewModel.initLoadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
        } completion: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

// MARK: Actions
extension TypePokemonViewController {
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
}

// MARK: TypePokemonViewModelDelegate
extension TypePokemonViewController: TypePokemonViewModelDelegate {
    
    func typePokemonViewModelDidLoadTypeInfos() {
        pickerView.reloadAllComponents()
        titleLabel.text = "\(viewModel.selectedTypeInfo?.typeNameText ?? "")"
    }
    
    func typePokemonViewModelDidLoadTypeInfosWithError() {
        loadingView.stopAnimating()
        ToastView.makeToast(viewController: self, text: "Something went wrong. Please check your internet connection and try again!").show()
    }
    
    func typePokemonViewModelDidLoadPokemonInfos(pokemonInfos: [PokemonInfo]) {
        collectionView.reloadData()
        loadingView.stopAnimating()
        collectionView.isHidden = false
        
        if viewModel.pokemonInfos.isEmpty {
            ToastView.makeToast(viewController: self, text: "Something went wrong. Please check your internet connection and try again!").show()
        }
        else {
            titleLabel.text = "\(viewModel.selectedTypeInfo?.typeNameText ?? "") (\(pokemonInfos.count))"
        }
    }
}

// MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension TypePokemonViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.typeInfos.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView()
        let typeNameView = TypeNameView()
        view.addSubview(typeNameView)
        
        typeNameView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        typeNameView.typeInfo = viewModel.typeInfos[row]
        
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        collectionView.isHidden = true
        loadingView.startAnimating()
        viewModel.selectedTypeIndex = row
        
        titleLabel.text = "\(viewModel.selectedTypeInfo?.typeNameText ?? "")"
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TypePokemonViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pokemonInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonListCell.identifier, for: indexPath) as! PokemonListCell
        cell.pokemonInfo = viewModel.pokemonInfos[indexPath.item]
        cell.isGridLayout = true
        cell.accessibilityIdentifier = "pokemonCell"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bottomPadding = AppDelegate.keyWindow?.safeAreaInsets.bottom ?? 0
        return .init(top: 12, left: 20, bottom: bottomPadding + 12, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: PokemonListCell.gridWidth, height: PokemonListCell.gridHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemonInfo = viewModel.pokemonInfos[indexPath.item]
        let vc = PokemonDetailViewController(pokemonInfo: pokemonInfo)
        present(vc, animated: true)
    }
}
