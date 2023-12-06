//
//  PokeManager.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/3.
//

import Foundation
import PokemonAPI

class PokeManager: NSObject {
    
    var myPokemonInfos: [PokemonInfo] = []
    
    var pokemonInfos: [PokemonInfo] = []
    
    var continuationKey: PKMPagedObject<PKMPokemon>?
    
    var nextKey: String?
    
    static let instance = PokeManager()
    
    static let MyPokemonListNeedUpdateNotification: String = "PokeManager_MyPokemonListNeedUpdateNotification"
    
    static let MyPokemonIdListKey: String = "PokeManager_MyPokemonIdList"
    
    // Check if pokemon is owned
    static func isMyPokemon(id: Int) -> Bool {
        let list = UserDefaults.standard.array(forKey: MyPokemonIdListKey) as? [Int] ?? []
        if list.firstIndex(of: id) != nil {
            return true
        }
        return false
    }
    
    // Save my pokemon id to UserDefaults
    static func addMyPokemonId(pokemonInfo: PokemonInfo) {
        GogoLogger.instance.logger.info("save my pokemon id to UserDefaults, id: \(pokemonInfo.id)")
        
        var list = UserDefaults.standard.array(forKey: MyPokemonIdListKey) as? [Int] ?? []
        if list.firstIndex(of: pokemonInfo.id) != nil {
            return
        }
        
        list.append(pokemonInfo.id)
        UserDefaults.standard.set(list, forKey: MyPokemonIdListKey)
        
        savePokemonInfosInstance(pokemonInfos: [pokemonInfo])
        PokeManager.instance.myPokemonInfos.append(pokemonInfo)
        PokeManager.instance.myPokemonInfos.sort { $0.id < $1.id }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyPokemonListNeedUpdateNotification), object: nil, userInfo: nil)
        
        GogoLogger.instance.logger.info("my pokemon count: \(PokeManager.instance.myPokemonInfos.count)")
    }
    
    // Remove my pokemon id from UserDefaults
    static func removeMyPokemonId(pokemonInfo: PokemonInfo) {
        GogoLogger.instance.logger.info("remove my pokemon id from UserDefaults, id: \(pokemonInfo.id)")
        
        var list = UserDefaults.standard.array(forKey: MyPokemonIdListKey) as? [Int] ?? []
        if let indexToRemove = list.firstIndex(of: pokemonInfo.id) {
            list.remove(at: indexToRemove)
            UserDefaults.standard.set(list, forKey: MyPokemonIdListKey)
            
            if let indexToRemove = PokeManager.instance.myPokemonInfos.firstIndex(where: { myPokemonInfo in
                myPokemonInfo.id == pokemonInfo.id
            }) {
                PokeManager.instance.myPokemonInfos.remove(at: indexToRemove)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyPokemonListNeedUpdateNotification), object: nil, userInfo: nil)
            }
        }
        
        GogoLogger.instance.logger.info("my pokemon count: \(PokeManager.instance.myPokemonInfos.count)")
    }
    
    // Save pokemon infos to UserDefaults
    static func savePokemonInfosInstance(pokemonInfos: [PokemonInfo]) {
        for pokemonInfo in pokemonInfos {
            GogoLogger.instance.logger.info("save pokemon info to UserDefaults, id: \(pokemonInfo.id)")
            
            let key = keyForPokemonInfo(id: pokemonInfo.id)
            
            if UserDefaults.standard.string(forKey: key) != nil {
                break
            }
            
            do {
                let jsonData = try JSONEncoder().encode(pokemonInfo)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    UserDefaults.standard.set(jsonString, forKey: key)
                }
            }
            catch {
                GogoLogger.instance.logger.error("❗JSON encoding error: \(error.localizedDescription)")
            }
        }
    }
    
    // Get pokemon info from UserDefaults by id
    static func loadPokemonInfoInstance(id: Int) -> PokemonInfo? {
        GogoLogger.instance.logger.info("get pokemon info from UserDefaults, id: \(id)")
        
        let key = keyForPokemonInfo(id: id)
        if let jsonString = UserDefaults.standard.string(forKey: key) {
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedPokemon = try jsonDecoder.decode(PokemonInfo.self, from: jsonData)
                    return decodedPokemon
                }
                catch {
                    GogoLogger.instance.logger.error("❗JSON encoding error: \(error.localizedDescription)")
                }
            }
        }
        return nil
    }
    
    static func keyForPokemonInfo(id: Int) -> String {
        return String(format: "PokemonInfo_Key_%04d", id)
    }
    
    // Fetching my pokemon
    static func fetchMyPokemonList(callback: @escaping (() -> Void)) {
        GogoLogger.instance.logger.info("fetching my pokemon")
        
        if !PokeManager.instance.myPokemonInfos.isEmpty {
            GogoLogger.instance.logger.info("my pokemon count: \(PokeManager.instance.myPokemonInfos.count)")
            callback()
            return
        }
        
        let idList = UserDefaults.standard.array(forKey: MyPokemonIdListKey) as? [Int] ?? []
        for id in idList {
            if let pokemonInfo = loadPokemonInfoInstance(id: id) {
                PokeManager.instance.myPokemonInfos.append(pokemonInfo)
            }
        }
        PokeManager.instance.myPokemonInfos.sort { $0.id < $1.id }
        GogoLogger.instance.logger.info("my pokemon count: \(PokeManager.instance.myPokemonInfos.count)")
        callback()
    }
    
    // Fetching pokemon list
    static func fetchPokemonList(reload: Bool, callback: @escaping ((Error?) -> Void)) {
        var paginationState: PaginationState<PKMPokemon> = .initial(pageLimit: 20)
        
        if reload {
            PokeManager.instance.pokemonInfos.removeAll()
            PokeManager.instance.continuationKey = nil
            
            GogoLogger.instance.logger.info("fetching pokemon list, page: 0")
        }
        else if let continuationKey = PokeManager.instance.continuationKey {
            paginationState = .continuing(continuationKey, .next)
            
            GogoLogger.instance.logger.info("fetching pokemon list, page: \(continuationKey.currentPage)")
        }
        
        PokemonAPI().pokemonService.fetchPokemonList(paginationState: paginationState) { result in
            
            switch result {
            case .success(let pagedObject):
                GogoLogger.instance.logger.info("fetching pokemon list success")
                
                PokeManager.instance.continuationKey = pagedObject
                
                fetchPokemonInfo(list: pagedObject.results) { pokemonInfos in
                    PokeManager.instance.pokemonInfos.append(contentsOf: pokemonInfos)
                    callback(nil)
                }
            case .failure(let error):
                GogoLogger.instance.logger.error("❗fetching pokemon list failure: \(error)")
                callback(error)
            }
        }
    }
    
    // Fetching pokemon infos by paged results
    static func fetchPokemonInfo(list: [PKMAPIResource<PKMPokemon>]?, list2: [PKMNamedAPIResource<PKMPokemon>]? = nil, callback: @escaping (([PokemonInfo]) -> Void)) {
        GogoLogger.instance.logger.info("fetching pokemon infos, count: \((list ?? list2)?.count ?? 0)")
        
        guard let list = list ?? list2, !list.isEmpty else {
            callback([])
            GogoLogger.instance.logger.info("fetching pokemon infos finished")
            return
        }
        
        var i: Int = 0
        var pokemonInfos: [PokemonInfo] = []
        for pokemonResource in list {
            PokemonAPI().resourceService.fetch(pokemonResource) { result in
                
                switch result {
                case .success(let pokemon):
                    if let id = pokemon.id {
                        
                        if let savedPokemon = loadPokemonInfoInstance(id: id) {
                            pokemonInfos.append(savedPokemon)
                            
                            i += 1
                            if i == list.count {
                                pokemonInfos.sort { $0.id < $1.id }
                                GogoLogger.instance.logger.info("fetching pokemon infos finished")
                                callback(pokemonInfos)
                            }
                            return
                        }
                        
                        let pokemonInfo = PokemonInfo(id: id, name: pokemon.name, frontDefault: pokemon.sprites?.frontDefault, frontFemale: pokemon.sprites?.frontFemale, height: pokemon.height, weight: pokemon.weight)
                        pokemonInfos.append(pokemonInfo)
                        
                        fetchPokemonTypes(pokemonTypes: pokemon.types ?? []) { typeInfos in
                            pokemonInfo.types = typeInfos
                            
                            fetchPokemonSpecies(species: pokemon.species) { pokemonSpecies, error in
                                fetchNames(names: pokemonSpecies?.names ?? [], source: "species") { pokemonNames in
                                    pokemonInfo.names = pokemonNames
                                    
                                    savePokemonInfosInstance(pokemonInfos: [pokemonInfo])
                                    
                                    i += 1
                                    if i == list.count {
                                        pokemonInfos.sort { $0.id < $1.id }
                                        GogoLogger.instance.logger.info("fetching pokemon infos finished")
                                        callback(pokemonInfos)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        i += 1
                        if i == list.count {
                            pokemonInfos.sort { $0.id < $1.id }
                            GogoLogger.instance.logger.info("fetching pokemon infos finished")
                            callback(pokemonInfos)
                        }
                    }
                case .failure(let error):
                    GogoLogger.instance.logger.error("❗fetching pokemon info failure: \(error)")
                    i += 1
                    if i == list.count {
                        pokemonInfos.sort { $0.id < $1.id }
                        GogoLogger.instance.logger.info("fetching pokemon infos finished")
                        callback(pokemonInfos)
                    }
                }
            }
        }
    }
    
    // Fetching pokemon types info
    private static func fetchPokemonTypes(pokemonTypes: [PKMPokemonType], callback: @escaping (([TypeInfo]) -> Void)) {
        GogoLogger.instance.logger.info("fetching pokemon type info, count: \(pokemonTypes.count)")
        
        guard !pokemonTypes.isEmpty else {
            callback([])
            return
        }
        
        var i: Int = 0
        var typeInfos: [TypeInfo] = []
        for pokemonType in pokemonTypes {
            if let typeResource = pokemonType.type {
                
                PokemonAPI().resourceService.fetch(typeResource) { result in
                    
                    switch result {
                    case .success(let type):
                        if let id = type.id {
                            
                            if let savedType = TypeManager.loadTypeInfoInstance(id: id) {
                                typeInfos.append(savedType)
                                
                                i += 1
                                if i == pokemonTypes.count {
                                    callback(typeInfos)
                                }
                                return
                            }
                            
                            let typeInfo = TypeInfo(id: id, typeName: type.name)
                            typeInfos.append(typeInfo)
                            
                            fetchNames(names: type.names ?? [], source: "type") { typeNames in
                                typeInfo.typeNames = typeNames
                                
                                i += 1
                                if i == pokemonTypes.count {
                                    callback(typeInfos)
                                }
                            }
                        }
                        else {
                            i += 1
                            if i == pokemonTypes.count {
                                callback(typeInfos)
                            }
                        }
                        
                    case .failure(let error):
                        GogoLogger.instance.logger.error("❗fetching pokemon type info failure: \(error)")
                        i += 1
                        if i == pokemonTypes.count {
                            callback(typeInfos)
                        }
                    }
                }
            }
            else {
                i += 1
                if i == pokemonTypes.count {
                    callback(typeInfos)
                }
            }
        }
    }
    
    // Fetching names
    static func fetchNames(names: [PKMName], source: String, callback: @escaping (([String: String]) -> Void)) {
        GogoLogger.instance.logger.info("fetching \(source) names, count: \(names.count)")
        
        guard !names.isEmpty else {
            callback([:])
            return
        }
        
        var i: Int = 0
        var typeNames: [String: String] = [:]
        for name in names {
            if let languageResource = name.language {
                PokemonAPI().resourceService.fetch(languageResource) { result in
                    
                    i += 1
                    
                    switch result {
                    case .success(let language):
                        if let languageName = language.name {
                            typeNames[languageName] = name.name
                        }
                        
                    case .failure(let error):
                        GogoLogger.instance.logger.error("❗fetching \(source) names failure: \(error)")
                    }
                    
                    if i == names.count {
                        callback(typeNames)
                    }
                }
            }
            else {
                i += 1
                if i == names.count {
                    callback(typeNames)
                }
            }
        }
    }
    
    // Fetching pokemon info by id
    static func fetchPokemon(id: Int, callback: @escaping ((PKMPokemon?, PokemonInfo?, Error?) -> Void)) {
        GogoLogger.instance.logger.info("fetching pokemon info, id: \(id)")
        
        PokemonAPI().pokemonService.fetchPokemon(id) { result in
            
            switch result {
            case .success(let pokemon):
                if let id = pokemon.id {
                    GogoLogger.instance.logger.info("fetching pokemon info success")
                    
                    if let savedPokemon = loadPokemonInfoInstance(id: id) {
                        callback(pokemon, savedPokemon, nil)
                        return
                    }
                    
                    let pokemonInfo = PokemonInfo(id: id, name: pokemon.name, frontDefault: pokemon.sprites?.frontDefault, frontFemale: pokemon.sprites?.frontFemale, height: pokemon.height, weight: pokemon.weight)
                    
                    fetchPokemonTypes(pokemonTypes: pokemon.types ?? []) { typeInfos in
                        pokemonInfo.types = typeInfos
                        
                        fetchPokemonSpecies(species: pokemon.species) { pokemonSpecies, error in
                            fetchNames(names: pokemonSpecies?.names ?? [], source: "species") { pokemonNames in
                                pokemonInfo.names = pokemonNames
                                
                                savePokemonInfosInstance(pokemonInfos: [pokemonInfo])
                                callback(pokemon, pokemonInfo, nil)
                            }
                        }
                    }
                }
                else {
                    GogoLogger.instance.logger.error("❗fetching pokemon info failure: id is nil")
                    callback(nil, nil, nil)
                }
                
            case .failure(let error):
                GogoLogger.instance.logger.error("❗fetching pokemon info failure: \(error)")
                callback(nil, nil, error)
            }
        }
    }
    
    // Fetching pokemon species
    static func fetchPokemonSpecies(species: PKMNamedAPIResource<PKMPokemonSpecies>?, callback: @escaping ((PKMPokemonSpecies?, Error?) -> Void)) {
        GogoLogger.instance.logger.info("fetching pokemon species")
        
        guard let speciesResource = species else {
            callback(nil, nil)
            return
        }
        
        PokemonAPI().resourceService.fetch(speciesResource) { result in
            switch result {
            case .success(let species):
                GogoLogger.instance.logger.info("fetching pokemon species success")
                callback(species, nil)
                
            case .failure(let error):
                GogoLogger.instance.logger.error("❗fetching pokemon species failure: \(error)")
                callback(nil, error)
            }
        }
    }
    
    // Fetching pokemon evolution chain
    static func fetchEvolutionChain(evolutionChain: PKMAPIResource<PKMEvolutionChain>?, callback: @escaping ((PKMClainLink?, Error?) -> Void)) {
        GogoLogger.instance.logger.info("fetching pokemon evolution chain")
        
        guard let evolutionChainResource = evolutionChain else {
            callback(nil, nil)
            return
        }
        
        PokemonAPI().resourceService.fetch(evolutionChainResource) { result in
            switch result {
            case .success(let evolutionChain):
                GogoLogger.instance.logger.info("fetching pokemon evolution chain success")
                callback(evolutionChain.chain, nil)
                
            case .failure(let error):
                GogoLogger.instance.logger.error("❗fetching pokemon evolution chain failure: \(error)")
                callback(nil, error)
            }
        }
    }
    
    // Extract evolution list from evolution chain
    static func extractEvolutionList(from chain: PKMClainLink) -> [PKMNamedAPIResource<PKMPokemonSpecies>] {
        var evolutionList: [PKMNamedAPIResource<PKMPokemonSpecies>] = []
        
        if let species = chain.species {
            evolutionList.append(species)
        }
        
        if let evolvesTo = chain.evolvesTo {
            for nextChain in evolvesTo {
                let nextEvolutionList = extractEvolutionList(from: nextChain)
                evolutionList.append(contentsOf: nextEvolutionList)
            }
        }
        
        return evolutionList
    }
    
    // Fetching pokemon stats
    static func fetchPokemonStats(stats: [PKMPokemonStat], callback: @escaping (([StatInfo]) -> Void)) {
        GogoLogger.instance.logger.info("fetching pokemon stats, count: \(stats.count)")
        
        guard !stats.isEmpty else {
            callback([])
            return
        }
        
        var i: Int = 0
        var statInfos: [StatInfo] = []
        for stat in stats {
            if let statResource = stat.stat {
                PokemonAPI().resourceService.fetch(statResource) { result in
                    
                    switch result {
                    case .success(let pokemonStat):
                        let statInfo = StatInfo(baseStat: stat.baseStat, statName: pokemonStat.name)
                        statInfos.append(statInfo)
                        
                        fetchNames(names: pokemonStat.names ?? [], source: "stat") { statNames in
                            statInfo.statNames = statNames
                            
                            i += 1
                            if i == stats.count {
                                callback(statInfos)
                            }
                        }
                        
                    case .failure(let error):
                        GogoLogger.instance.logger.error("❗fetching pokemon stats failure: \(error)")
                        i += 1
                        if i == stats.count {
                            callback(statInfos)
                        }
                    }
                }
            }
            else {
                i += 1
                if i == stats.count {
                    callback(statInfos)
                }
            }
        }
    }
}
