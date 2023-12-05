//
//  TypePokemonViewModel.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/5.
//

import Foundation
import PokemonAPI

protocol TypePokemonViewModelDelegate : AnyObject {
    func typePokemonViewModelDidLoadTypeInfos()
    func typePokemonViewModelDidLoadTypeInfosWithError()
    func typePokemonViewModelDidLoadPokemonInfos(pokemonInfos: [PokemonInfo])
}

class TypePokemonViewModel {
    
    weak var delegate: TypePokemonViewModelDelegate?
    
    var typeInfos: [TypeInfo] {
        return TypeManager.instance.typeInfos
    }
    
    var selectedTypeIndex: Int? {
        didSet {
            if let selectedTypeIndex = selectedTypeIndex {
                fetchPokemonInfo(typeInfo: typeInfos[selectedTypeIndex])
            }
        }
    }
    
    var selectedTypeInfo: TypeInfo? {
        if let selectedTypeIndex = selectedTypeIndex {
            return typeInfos[selectedTypeIndex]
        }
        return nil
    }
    
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
            selectedTypeIndex = 0
            delegate?.typePokemonViewModelDidLoadTypeInfos()
        }
        else {
            delegate?.typePokemonViewModelDidLoadTypeInfosWithError()
        }
    }
    
    func fetchPokemonInfo(typeInfo: TypeInfo) {
        TypeManager.fetchType(id: typeInfo.id) { type, error in
            let list = type?.pokemon?.compactMap { $0.pokemon }
            PokeManager.fetchPokemonInfo(list: nil, list2: list) { [weak self] pokemonInfos in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    self.pokemonInfos = pokemonInfos
                    self.delegate?.typePokemonViewModelDidLoadPokemonInfos(pokemonInfos: pokemonInfos)
                }
            }
        }
    }
}
