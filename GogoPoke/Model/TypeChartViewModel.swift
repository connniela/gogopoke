//
//  TypeChartViewModel.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/4.
//

import Foundation
import PokemonAPI

enum Relations: Int, CaseIterable {
    case attack
    case defense
}

protocol TypeChartViewModelDelegate : AnyObject {
    func typeChartViewModelDidLoadTypeInfos()
    func typeChartViewModelDidLoadTypeInfosWithError()
    func typeChartViewModelDidLoadDamageRelations()
    func typeChartViewModelDidLoadSecondDamageRelations()
}


class TypeChartViewModel {
    
    weak var delegate: TypeChartViewModelDelegate?
    
    var relations: Relations = .attack {
        didSet {
            if let selectedTypeIndex = selectedTypeIndex {
                fetchDamageRelations(typeInfo: typeInfos[selectedTypeIndex])
                fetchSecondDamageRelations(typeInfo: secondTypeInfos[selectedSecondTypeIndex])
            }
        }
    }
    
    var typeInfos: [TypeInfo] {
        return TypeManager.instance.typeInfos
    }
    
    var selectedTypeIndex: Int? {
        didSet {
            if let selectedTypeIndex = selectedTypeIndex {
                
                secondTypeInfos.removeAll()
                let noneTypeInfo = TypeInfo(id: 0, typeName: "None")
                let filterTypeInfos = typeInfos.filter { $0.id != typeInfos[selectedTypeIndex].id }
                secondTypeInfos.append(noneTypeInfo)
                secondTypeInfos.append(contentsOf: filterTypeInfos)
                selectedSecondTypeIndex = 0
                
                fetchDamageRelations(typeInfo: typeInfos[selectedTypeIndex])
            }
        }
    }
    
    var secondTypeInfos: [TypeInfo] = []
    
    var selectedSecondTypeIndex: Int = 0 {
        didSet {
            fetchSecondDamageRelations(typeInfo: secondTypeInfos[selectedSecondTypeIndex])
        }
    }
    
    var selectedTypeInfo: TypeInfo?
    
    var selectedSecondTypeInfo: TypeInfo?
    
    var pokemonInfos: [PokemonInfo] = []
    
    func initLoadData() {
        if !TypeManager.instance.typeInfos.isEmpty {
            refreshTypeInfos()
            return
        }
        
        if TypeManager.instance.loadingTypeInfos {
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTypeInfos), name: NSNotification.Name(rawValue: TypeManager.TypeInfosNeedUpdateNotification), object: nil)
            return
        }
        
        TypeManager.fetchTypeList { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.refreshTypeInfos()
            }
        }
    }
    
    @objc func refreshTypeInfos() {
        if !typeInfos.isEmpty {
            delegate?.typeChartViewModelDidLoadTypeInfos()
            selectedTypeIndex = 0
        }
        else {
            delegate?.typeChartViewModelDidLoadTypeInfosWithError()
        }
    }
    
    func fetchDamageRelations(typeInfo: TypeInfo) {
        TypeManager.fetchType(id: typeInfo.id) { type, error in
            TypeManager.fetchDamageRelations(damageRelations: type?.damageRelations) { [weak self] relations in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    typeInfo.noDamageTo = relations?[0] ?? []
                    typeInfo.halfDamageTo = relations?[1] ?? []
                    typeInfo.doubleDamageTo = relations?[2] ?? []
                    typeInfo.noDamageFrom = relations?[3] ?? []
                    typeInfo.halfDamageFrom = relations?[4] ?? []
                    typeInfo.doubleDamageFrom = relations?[5] ?? []
                    self.selectedTypeInfo = typeInfo
                    self.delegate?.typeChartViewModelDidLoadDamageRelations()
                }
            }
        }
    }
    
    func fetchSecondDamageRelations(typeInfo: TypeInfo) {
        if typeInfo.id == 0 {
            selectedSecondTypeInfo = nil
            return
        }
        
        TypeManager.fetchType(id: typeInfo.id) { type, error in
            TypeManager.fetchDamageRelations(damageRelations: type?.damageRelations) { [weak self] relations in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    typeInfo.noDamageTo = relations?[0] ?? []
                    typeInfo.halfDamageTo = relations?[1] ?? []
                    typeInfo.doubleDamageTo = relations?[2] ?? []
                    typeInfo.noDamageFrom = relations?[3] ?? []
                    typeInfo.halfDamageFrom = relations?[4] ?? []
                    typeInfo.doubleDamageFrom = relations?[5] ?? []
                    self.selectedSecondTypeInfo = typeInfo
                    self.delegate?.typeChartViewModelDidLoadSecondDamageRelations()
                }
            }
        }
    }
    
    func checkDamageRelationsWithError() -> Bool {
        if let selectedTypeInfo = selectedTypeInfo {
            if let selectedSecondTypeInfo = selectedSecondTypeInfo {
                if selectedSecondTypeInfo.noDamageTo.isEmpty &&
                    selectedSecondTypeInfo.halfDamageTo.isEmpty &&
                    selectedSecondTypeInfo.doubleDamageTo.isEmpty {
                    return true
                }
            }
            
            if selectedTypeInfo.noDamageTo.isEmpty &&
                selectedTypeInfo.halfDamageTo.isEmpty &&
                selectedTypeInfo.doubleDamageTo.isEmpty {
                return true
            }
            
            return false
        }
        return true
    }
}
