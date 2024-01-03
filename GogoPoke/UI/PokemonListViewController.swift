//
//  PokemonListViewController.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/2.
//

import UIKit
import SnapKit

class PokemonListViewController: UIViewController {
    
    private let viewModel = PokemonListViewModel()
    
    private let segmentedControl = SegmentedControl()
    private let switchLayoutButton = UIButton()
    private var collectionView: UICollectionView!
    private let emptyLabel = UILabel()
    private let loadingView = LoadingView()
    
    private var isGridLayout: Bool = false
    
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
        view.backgroundColor = .swablu300Color
        
        let topBarBg = UIView()
        topBarBg.backgroundColor = .swablu700Color
        topBarBg.layer.shadowOffset = .init(width: 0, height: 2)
        topBarBg.layer.shadowColor = UIColor.swablu700Color.cgColor
        topBarBg.layer.shadowOpacity = 1
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        switchLayoutButton.setImage(UIImage(named: "grid")?.withRenderingMode(.alwaysTemplate), for: .normal)
        switchLayoutButton.imageView?.tintColor = .white
        switchLayoutButton.addTarget(self, action: #selector(switchLayoutButtonTapped), for: .touchUpInside)
        
        segmentedControl.insertSegment(withTitle: "All Pokémon", at: segmentedControl.numberOfSegments, animated: false)
        segmentedControl.insertSegment(withTitle: "My Pokémon", at: segmentedControl.numberOfSegments, animated: false)
        segmentedControl.addTarget(self, action: #selector(segmentedControlSelectedIndexDidChange), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        
        let topBar = UIView()
        
        topBar.addSubview(backButton)
        topBar.addSubview(switchLayoutButton)
        topBar.addSubview(segmentedControl)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
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
        
        backButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(48)
            make.leading.equalToSuperview().inset(16)
        }
        
        switchLayoutButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
            make.trailing.equalToSuperview().inset(16)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.trailing.equalTo(switchLayoutButton.snp.leading).offset(-16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyLabel.isHidden = true
        emptyLabel.textColor = .swablu900Color
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.text = "There's no owned Pokémon.\nYou can set them up on the Pokémon page."
        
        view.addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView).offset(48)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        view.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.top.equalTo(collectionView).offset(24)
            make.centerX.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GogoLogger.instance.logger.info("🎒Open Pokémon list")
        
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
    
    private var pokemonInfos: [PokemonInfo] {
        if segmentedControl.selectedSegmentIndex == 0 {
            return viewModel.pokemonInfos
        }
        else {
            return viewModel.myPokemonInfos
        }
    }
}

// MARK: Actions
extension PokemonListViewController {
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func switchLayoutButtonTapped() {
        if pokemonInfos.isEmpty {
            ToastView.makeToast(viewController: self, text: "There's no Pokémon.").show()
            return
        }
        
        isGridLayout = !isGridLayout
        if isGridLayout {
            switchLayoutButton.setImage(UIImage(named: "list")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        else {
            switchLayoutButton.setImage(UIImage(named: "grid")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    @objc private func segmentedControlSelectedIndexDidChange() {
        collectionView.reloadData()
        updateEmptyLabel()
    }
    
    @objc private func refreshMyPokemonList() {
        if segmentedControl.selectedSegmentIndex == 1 {
            collectionView.reloadSections(IndexSet(integer: 0))
            updateEmptyLabel()
        }
    }
}

// MARK: Privates
extension PokemonListViewController {
    
    private func updateEmptyLabel() {
        if segmentedControl.selectedSegmentIndex == 1 && pokemonInfos.isEmpty {
            emptyLabel.isHidden = false
            return
        }
        
        emptyLabel.isHidden = true
    }
}

// MARK: PokemonListViewModelDelegate
extension PokemonListViewController: PokemonListViewModelDelegate {
    
    func pokemonListViewModelDidRefetchData() {
        collectionView.reloadData()
        loadingView.stopAnimating()
        updateEmptyLabel()
        
        if segmentedControl.selectedSegmentIndex == 0 && viewModel.error != nil {
            ToastView.makeToast(viewController: self, text: "Something went wrong. Please check your internet connection and try again!").show()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: PokeManager.MyPokemonListNeedUpdateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshMyPokemonList), name: NSNotification.Name(rawValue: PokeManager.MyPokemonListNeedUpdateNotification), object: nil)
    }
    
    func pokemonListViewModelDidLoadNextPage() {
        collectionView.reloadSections(IndexSet(integer: 0))
        
        if segmentedControl.selectedSegmentIndex == 0 && viewModel.error != nil {
            ToastView.makeToast(viewController: self, text: "Something went wrong. Please check your internet connection and try again!").show()
        }
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension PokemonListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonListCell.identifier, for: indexPath) as! PokemonListCell
        cell.pokemonInfo = pokemonInfos[indexPath.item]
        cell.isGridLayout = isGridLayout
        cell.accessibilityIdentifier = "pokemonCell"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bottomPadding = AppDelegate.keyWindow?.safeAreaInsets.bottom ?? 0
        return .init(top: 12, left: 20, bottom: bottomPadding + 12, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridLayout {
            return .init(width: PokemonListCell.gridWidth, height: PokemonListCell.gridHeight)
        }
        else {
            return .init(width: collectionView.bounds.width - 20 * 2, height: PokemonListCell.listHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 && indexPath.item > pokemonInfos.count - 8 {
            viewModel.loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemonInfo = pokemonInfos[indexPath.item]
        let vc = PokemonDetailViewController(pokemonInfo: pokemonInfo)
        present(vc, animated: true)
    }
    
}
