//
//  PokemonListViewModel.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/2.
//

import Foundation
import PokemonAPI

protocol PokemonListViewModelDelegate : AnyObject {
    func pokemonListViewModelDidRefetchData()
    func pokemonListViewModelDidLoadNextPage()
}

class PokemonListViewModel {
    
    weak var delegate: PokemonListViewModelDelegate?
    
    var myPokemonInfos: [PokemonInfo] {
        return PokeManager.instance.myPokemonInfos
    }
    
    var pokemonInfos: [PokemonInfo] {
        return PokeManager.instance.pokemonInfos
    }
    
    var continuationKey: PKMPagedObject<PKMPokemon>? {
        return PokeManager.instance.continuationKey
    }
    
    var allLoadingCompleted: Bool {
        if let continuationKey = continuationKey {
            return !continuationKey.hasNext
        }
        return !pokemonInfos.isEmpty
    }
    
    var loading = false
    
    var error: Error? = nil
    
    func initLoadData() {
        PokeManager.fetchMyPokemonList { [weak self] in
            guard let self = self else { return }
            
            if self.pokemonInfos.isEmpty {
                self.refetchData()
            }
            else {
                self.delegate?.pokemonListViewModelDidRefetchData()
            }
        }
    }
    
    func refetchData() {
        loading = true
        error = nil
        
        PokeManager.fetchPokemonList(reload: true) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.loading = false
                self.error = error
                self.delegate?.pokemonListViewModelDidRefetchData()
            }
        }
    }
    
    func loadNextPage() {
        if loading || allLoadingCompleted || error != nil {
            return
        }
        
        loading = true
        
        PokeManager.fetchPokemonList(reload: false) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.loading = false
                self.error = error
                self.delegate?.pokemonListViewModelDidLoadNextPage()
            }
        }
    }
}
