//
//  PokemonDetailViewModel.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/2.
//

import Foundation
import PokemonAPI

protocol PokemonDetailViewModelDelegate : AnyObject {
    func pokemonDetailViewModelDidLoadPokemon()
    func pokemonDetailViewModelDidLoadPokemonWithError()
    func pokemonDetailViewModelDidInitEvolutionChain(count: Int)
    func pokemonDetailViewModelDidLoadEvolutionChain(pokemonInfo: PokemonInfo, index: Int)
    func pokemonDetailViewModelDidLoadPokemonStats(stats: [StatInfo])
    func pokemonDetailViewModelDidLoadFlavorText(text: String?)
}

class PokemonDetailViewModel {
    
    weak var delegate: PokemonDetailViewModelDelegate?
    
    var pokemonInfo: PokemonInfo? {
        didSet {
            if let pokemonInfo = pokemonInfo {
                isMyPokemon = PokeManager.isMyPokemon(id: pokemonInfo.id)
            }
        }
    }
    
    var isMyPokemon: Bool = false
    
    var pokemon: PKMPokemon?
    
    var clainLink: PKMClainLink?
    
    func fetchPokemon(id: Int) {
        PokeManager.fetchPokemon(id: id) { [weak self] pokemon, pokemonInfo, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if pokemonInfo != nil {
                    self.pokemonInfo = pokemonInfo
                    self.delegate?.pokemonDetailViewModelDidLoadPokemon()
                }
                else {
                    self.delegate?.pokemonDetailViewModelDidLoadPokemonWithError()
                }
                
                self.fetchPokemonSpecies(pokemon: pokemon)
                self.fetchPokemonStats(pokemon: pokemon)
            }
        }
    }
    
    func fetchPokemonSpecies(pokemon: PKMPokemon?) {
        guard let pokemon = pokemon else { return }
        
        PokeManager.fetchPokemonSpecies(species: pokemon.species) { [weak self] pokemonSpecies, error in
            guard let self = self else { return }
            
            if let pokemonSpecies = pokemonSpecies {
                
                self.fetchFlavorText(flavorTextEntries: pokemonSpecies.flavorTextEntries)
                
                if clainLink == nil {
                    self.fetchEvolutionChain(evolutionChain: pokemonSpecies.evolutionChain)
                }
            }
        }
    }
    
    func fetchFlavorText(flavorTextEntries: [PKMFlavorText]?) {
        guard let flavorTextEntries = flavorTextEntries else { return }
        
        let systemLocale = SystemLocaleUtil.deviceLocaleName()
        var text: String?
        for flavorText in flavorTextEntries {
            if flavorText.language?.name == systemLocale {
                text = flavorText.flavorText
                break
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.pokemonDetailViewModelDidLoadFlavorText(text: text)
        }
    }
    
    func fetchEvolutionChain(evolutionChain: PKMAPIResource<PKMEvolutionChain>?) {
        guard let evolutionChain = evolutionChain else { return }
        
        PokeManager.fetchEvolutionChain(evolutionChain: evolutionChain) { [weak self] clainLink, error in
            if let clainLink = clainLink {
                let evolutionList = PokeManager.extractEvolutionList(from: clainLink)
                
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    self.clainLink = clainLink
                    self.delegate?.pokemonDetailViewModelDidInitEvolutionChain(count: evolutionList.count)
                    
                    for i in 0..<evolutionList.count {
                        self.fetchEvolutionSpecies(species: evolutionList[i], index: i)
                    }
                }
            }
        }
    }
    
    func fetchEvolutionSpecies(species: PKMNamedAPIResource<PKMPokemonSpecies>, index: Int) {
        PokeManager.fetchPokemonSpecies(species: species) { pokemonSpecies, error in
            if let pokemonSpecies = pokemonSpecies, let id = pokemonSpecies.id {
                PokeManager.fetchPokemon(id: id) { [weak self] pokemon, pokemonInfo, error in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        if let pokemonInfo = pokemonInfo {
                            self.delegate?.pokemonDetailViewModelDidLoadEvolutionChain(pokemonInfo: pokemonInfo, index: index)
                        }
                    }
                }
            }
        }
    }
    
    func fetchPokemonStats(pokemon: PKMPokemon?) {
        guard let pokemon = pokemon else { return }
        
        PokeManager.fetchPokemonStats(stats: pokemon.stats ?? []) { [weak self] statInfos in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.delegate?.pokemonDetailViewModelDidLoadPokemonStats(stats: statInfos)
            }
        }
    }
}
