//
//  TypeChartViewController.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/4.
//

import UIKit
import SnapKit

class TypeChartViewController: UIViewController {
    
    private let viewModel = TypeChartViewModel()
    
    private let segmentedControl = SegmentedControl()
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
        
        segmentedControl.insertSegment(withTitle: "As Attacker", at: segmentedControl.numberOfSegments, animated: false)
        segmentedControl.insertSegment(withTitle: "As Defender", at: segmentedControl.numberOfSegments, animated: false)
        segmentedControl.addTarget(self, action: #selector(segmentedControlSelectedIndexDidChange), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.accessibilityIdentifier = "typeSegmentedControl"
        
        let topBar = UIView()
        
        topBar.addSubview(backButton)
        topBar.addSubview(segmentedControl)
        
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
        
        segmentedControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(64)
        }
        
        let type1Label = UILabel()
        type1Label.text = "Type 1"
        type1Label.textColor = .swablu700Color
        type1Label.font = .systemFont(ofSize: 10)
        type1Label.textAlignment = .center
        
        let type2Label = UILabel()
        type2Label.text = "Type 2"
        type2Label.textColor = .swablu700Color
        type2Label.font = .systemFont(ofSize: 10)
        type2Label.textAlignment = .center
        
        let hStack = UIStackView(arrangedSubviews: [type1Label, type2Label])
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        hStack.spacing = 0
        
        view.addSubview(hStack)
        
        hStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
            make.height.equalTo(28)
        }
        
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(hStack.snp.bottom)
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
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
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
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        collectionView.register(TypeInfoCell.self, forCellWithReuseIdentifier: TypeInfoCell.identifier)
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
extension TypeChartViewController {
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func segmentedControlSelectedIndexDidChange() {
        if segmentedControl.selectedSegmentIndex == 0 {
            viewModel.relations = .attack
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            viewModel.relations = .defense
        }
    }
}

// MARK: Privates
extension TypeChartViewController {
    
    private func refreshCollectionView() {
        collectionView.reloadData()
        loadingView.stopAnimating()
        collectionView.isHidden = false
        
        if viewModel.checkDamageRelationsWithError() {
            ToastView.makeToast(viewController: self, text: "Something went wrong. Please check your internet connection and try again!").show()
        }
    }
}

// MARK: TypeChartViewModelDelegate
extension TypeChartViewController: TypeChartViewModelDelegate {
    
    func typeChartViewModelDidLoadTypeInfos() {
        pickerView.reloadAllComponents()
    }
    
    func typeChartViewModelDidLoadTypeInfosWithError() {
        loadingView.stopAnimating()
        ToastView.makeToast(viewController: self, text: "Something went wrong. Please check your internet connection and try again!").show()
    }
    
    func typeChartViewModelDidLoadDamageRelations() {
        pickerView.reloadComponent(Components.type2.rawValue)
        pickerView.selectRow(viewModel.selectedSecondTypeIndex, inComponent: Components.type2.rawValue, animated: true)
        if viewModel.selectedSecondTypeIndex == 0 {
            refreshCollectionView()
        }
    }
    
    func typeChartViewModelDidLoadSecondDamageRelations() {
        refreshCollectionView()
    }
}

// MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension TypeChartViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum Components: Int, CaseIterable {
        case type1
        case type2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Components.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch Components(rawValue: component) {
        case .type1:
            return viewModel.typeInfos.count
        case .type2:
            return viewModel.secondTypeInfos.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView()
        let typeNameView = TypeNameView()
        view.addSubview(typeNameView)
        
        typeNameView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        if Components(rawValue: component) == .type1 {
            typeNameView.typeInfo = viewModel.typeInfos[row]
        }
        else if Components(rawValue: component) == .type2 {
            typeNameView.typeInfo = viewModel.secondTypeInfos[row]
        }
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        collectionView.isHidden = true
        loadingView.startAnimating()
        
        if Components(rawValue: component) == .type1 {
            viewModel.selectedTypeIndex = row
        }
        else if Components(rawValue: component) == .type2 {
            viewModel.selectedSecondTypeIndex = row
        }
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TypeChartViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum Sections: Int, CaseIterable {
        case typeChart
        case pokemons
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.typeInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeInfoCell.identifier, for: indexPath) as! TypeInfoCell
        cell.typeInfo = viewModel.typeInfos[indexPath.item]
        if viewModel.relations == .attack {
            cell.calculateAttackMultipliers(typeInfo1: viewModel.selectedTypeInfo, typeInfo2: viewModel.selectedSecondTypeInfo)
        }
        else {
            cell.calculateDefenseMultipliers(typeInfo1: viewModel.selectedTypeInfo, typeInfo2: viewModel.selectedSecondTypeInfo)
        }
        cell.accessibilityIdentifier = "typeInfoCell"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bottomPadding = AppDelegate.instance.keyWindow?.safeAreaInsets.bottom ?? 0
        return .init(top: 12, left: 16, bottom: bottomPadding + 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: (collectionView.bounds.width - 16 * 2) / 2, height: TypeInfoCell.height)
    }
}

fileprivate class TypeInfoCell: UICollectionViewCell {
    static let identifier = "TypeInfoCell"
    static let height: CGFloat = 48
    
    private let typeNameView = TypeNameView()
    private let effectiveView = EffectiveView()
    
    var typeInfo: TypeInfo? {
        didSet {
            if let typeInfo = typeInfo {
                typeNameView.typeInfo = typeInfo
            }
        }
    }
    
    func calculateAttackMultipliers(typeInfo1: TypeInfo?, typeInfo2: TypeInfo?) {
        guard let typeInfo = typeInfo, let typeInfo1 = typeInfo1 else {
            effectiveView.effective = .normal
            return
        }
        
        let noDamageTo = typeInfo1.noDamageTo + (typeInfo2?.noDamageTo ?? [])
        let noDamageToCount = noDamageTo.filter({ $0.id == typeInfo.id }).count
        if noDamageToCount > 0 {
            effectiveView.effective = .noEffect
            return
        }
        
        let halfDamageTo = typeInfo1.halfDamageTo + (typeInfo2?.halfDamageTo ?? [])
        let halfDamageToCount = halfDamageTo.filter({ $0.id == typeInfo.id }).count
        if halfDamageToCount > 0 {
            if halfDamageToCount > 1 {
                effectiveView.effective = .notVeryVeryEffective
                return
            }
            effectiveView.effective = .notVeryEffective
            return
        }
        
        let doubleDamageTo = typeInfo1.doubleDamageTo + (typeInfo2?.doubleDamageTo ?? [])
        let doubleDamageToCount = doubleDamageTo.filter({ $0.id == typeInfo.id }).count
        if doubleDamageToCount > 0 {
            if doubleDamageToCount > 1 {
                effectiveView.effective = .superSuperEffective
                return
            }
            effectiveView.effective = .superEffective
            return
        }
        
        effectiveView.effective = .normal
    }
    
    func calculateDefenseMultipliers(typeInfo1: TypeInfo?, typeInfo2: TypeInfo?) {
        guard let typeInfo = typeInfo, let typeInfo1 = typeInfo1 else {
            effectiveView.effective = .normal
            return
        }
        
        let noDamageFrom = typeInfo1.noDamageFrom + (typeInfo2?.noDamageFrom ?? [])
        let noDamageFromCount = noDamageFrom.filter({ $0.id == typeInfo.id }).count
        if noDamageFromCount > 0 {
            effectiveView.effective = .noEffect
            return
        }
        
        let halfDamageFrom = typeInfo1.halfDamageFrom + (typeInfo2?.halfDamageFrom ?? [])
        let halfDamageFromCount = halfDamageFrom.filter({ $0.id == typeInfo.id }).count
        if halfDamageFromCount > 0 {
            if halfDamageFromCount > 1 {
                effectiveView.effective = .notVeryVeryEffective
                return
            }
            effectiveView.effective = .notVeryEffective
            return
        }
        
        let doubleDamageFrom = typeInfo1.doubleDamageFrom + (typeInfo2?.doubleDamageFrom ?? [])
        let doubleDamageFromCount = doubleDamageFrom.filter({ $0.id == typeInfo.id }).count
        if doubleDamageFromCount > 0 {
            if doubleDamageFromCount > 1 {
                effectiveView.effective = .superSuperEffective
                return
            }
            effectiveView.effective = .superEffective
            return
        }
        
        effectiveView.effective = .normal
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundView = nil
        backgroundColor = .clear
        
        let typeView = UIView()
        
        let keyView = UIView()
        
        let hStack = UIStackView(arrangedSubviews: [typeView, keyView])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.alignment = .fill
        hStack.distribution = .fillEqually
        
        addSubview(hStack)
        
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        typeView.addSubview(typeNameView)
        
        typeNameView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
        
        keyView.addSubview(effectiveView)
        
        effectiveView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(32)
        }
    }
}

fileprivate class EffectiveView: UIView {
    
    enum Effective: Int, CaseIterable {
        case noEffect
        case notVeryVeryEffective
        case notVeryEffective
        case normal
        case superEffective
        case superSuperEffective
    }
    
    private let label = UILabel()
    
    var effective: Effective? {
        didSet {
            if let effective = effective {
                if effective == .noEffect {
                    label.text = "0"
                    backgroundColor = UIColor(hex: 0x2e3436)
                }
                else if effective == .notVeryVeryEffective {
                    label.text = "¼"
                    backgroundColor = UIColor(hex: 0x7c0000)
                }
                else if effective == .notVeryEffective {
                    label.text = "½"
                    backgroundColor = UIColor(hex: 0xa40000)
                }
                else if effective == .normal {
                    label.text = nil
                    backgroundColor = .clear
                }
                else if effective == .superEffective {
                    label.text = "2"
                    backgroundColor = UIColor(hex: 0x4e9a06)
                }
                else if effective == .superSuperEffective {
                    label.text = "4"
                    backgroundColor = UIColor(hex: 0x73d216)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.swablu800Color.cgColor
        
        label.textColor = .pikachu200Color
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().inset(4)
            make.trailing.lessThanOrEqualToSuperview().inset(4)
            make.top.greaterThanOrEqualToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().inset(4)
            make.center.equalToSuperview()
        }
    }
}
