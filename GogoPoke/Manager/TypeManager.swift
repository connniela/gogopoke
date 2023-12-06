//
//  TypeManager.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/4.
//

import Foundation
import PokemonAPI

class TypeManager: NSObject {
    
    var typeInfos: [TypeInfo] = []
    
    var loadingTypeInfos: Bool = false
    
    static let instance = TypeManager()
    
    static let TypeInfosNeedUpdateNotification: String = "TypeManager_TypeInfosNeedUpdateNotification"
    
    // Save type infos to UserDefaults
    static func saveTypeInfosInstance(typeInfos: [TypeInfo]) {
        for typeInfo in typeInfos {
            GogoLogger.instance.logger.info("save type info to UserDefaults, id: \(typeInfo.id)")
            
            let key = keyForTypeInfo(id: typeInfo.id)
            
            if UserDefaults.standard.string(forKey: key) != nil {
                break
            }
            
            do {
                let jsonData = try JSONEncoder().encode(typeInfo)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    UserDefaults.standard.set(jsonString, forKey: key)
                }
            }
            catch {
                GogoLogger.instance.logger.error("❗JSON encoding error: \(error.localizedDescription)")
            }
        }
    }
    
    // Get type info from UserDefaults by id
    static func loadTypeInfoInstance(id: Int) -> TypeInfo? {
        GogoLogger.instance.logger.info("get type info from UserDefaults, id: \(id)")
        
        let key = keyForTypeInfo(id: id)
        if let jsonString = UserDefaults.standard.string(forKey: key) {
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedType = try jsonDecoder.decode(TypeInfo.self, from: jsonData)
                    return decodedType
                }
                catch {
                    GogoLogger.instance.logger.error("❗JSON encoding error: \(error.localizedDescription)")
                }
            }
        }
        return nil
    }
    
    static func keyForTypeInfo(id: Int) -> String {
        return String(format: "TypeInfo_Key_%04d", id)
    }
    
    // Fetching type list
    static func fetchTypeList(continuationKey: PKMPagedObject<PKMType>? = nil, callback: ((Error?) -> Void)? = nil) {
        var paginationState: PaginationState<PKMType> = .initial(pageLimit: 20)
        
        if let continuationKey = continuationKey, continuationKey.hasNext {
            paginationState = .continuing(continuationKey, .next)
            
            GogoLogger.instance.logger.info("fetching type list, page: \(continuationKey.currentPage)")
        }
        else {
            GogoLogger.instance.logger.info("fetching type list, page: 0")
        }
        
        TypeManager.instance.loadingTypeInfos = true
        
        PokemonAPI().pokemonService.fetchTypeList(paginationState: paginationState) { result in
            switch result {
            case .success(let pagedObject):
                GogoLogger.instance.logger.info("fetching type list success")
                
                fetchTypeInfo(list: pagedObject.results) { typeInfos in
                    TypeManager.instance.typeInfos.append(contentsOf: typeInfos)
                    
                    if pagedObject.hasNext {
                        fetchTypeList(continuationKey: pagedObject, callback: callback)
                    }
                    else {
                        TypeManager.instance.loadingTypeInfos = false
                        TypeManager.instance.typeInfos.sort { $0.id < $1.id }
                        callback?(nil)
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TypeInfosNeedUpdateNotification), object: nil, userInfo: nil)
                        }
                    }
                }
            case .failure(let error):
                GogoLogger.instance.logger.error("❗fetching type list failure: \(error)")
                TypeManager.instance.loadingTypeInfos = false
                callback?(error)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: TypeInfosNeedUpdateNotification), object: nil, userInfo: nil)
                }
            }
        }
    }
    
    // Fetching type infos by paged results
    private static func fetchTypeInfo(list: [PKMAPIResource<PKMType>]?, callback: @escaping (([TypeInfo]) -> Void)) {
        GogoLogger.instance.logger.info("fetching type infos, count: \(list?.count ?? 0)")
        
        guard let list = list, !list.isEmpty else {
            GogoLogger.instance.logger.info("fetching type infos finished")
            callback([])
            return
        }
        
        var i: Int = 0
        var typeInfos: [TypeInfo] = []
        for typeResource in list {
            PokemonAPI().resourceService.fetch(typeResource) { result in
                
                switch result {
                case .success(let type):
                    if let id = type.id, !(type.pokemon?.isEmpty ?? true) {
                        
                        if let savedType = loadTypeInfoInstance(id: id) {
                            typeInfos.append(savedType)
                            
                            i += 1
                            if i == list.count {
                                GogoLogger.instance.logger.info("fetching type infos finished")
                                callback(typeInfos)
                            }
                            return
                        }
                        
                        let typeInfo = TypeInfo(id: id, typeName: type.name)
                        typeInfos.append(typeInfo)
                        
                        PokeManager.fetchNames(names: type.names ?? [], source: "type") { typeNames in
                            typeInfo.typeNames = typeNames
                            
                            saveTypeInfosInstance(typeInfos: [typeInfo])
                            
                            i += 1
                            if i == list.count {
                                GogoLogger.instance.logger.info("fetching type infos finished")
                                callback(typeInfos)
                            }
                        }
                    }
                    else {
                        GogoLogger.instance.logger.error("❗fetching type info failure: no pokemon with type")
                        i += 1
                        if i == list.count {
                            GogoLogger.instance.logger.info("fetching type infos finished")
                            callback(typeInfos)
                        }
                    }
                    
                case .failure(let error):
                    GogoLogger.instance.logger.error("❗fetching type info failure: \(error)")
                    i += 1
                    if i == list.count {
                        GogoLogger.instance.logger.info("fetching type infos finished")
                        callback(typeInfos)
                    }
                }
            }
        }
    }
    
    // Fetching type info by id
    static func fetchType(id: Int, callback: @escaping ((PKMType?, Error?) -> Void)) {
        GogoLogger.instance.logger.info("fetching type info, id: \(id)")
        
        PokemonAPI().pokemonService.fetchType(id) { result in
            switch result {
            case .success(let type):
                GogoLogger.instance.logger.info("fetching type info success")
                callback(type, nil)
            case .failure(let error):
                GogoLogger.instance.logger.error("❗fetching type info failure: \(error)")
                callback(nil, error)
            }
        }
    }
    
    // Fetching damage relations
    static func fetchDamageRelations(damageRelations: PKMTypeRelations?, callback: @escaping (([[TypeInfo]]?) -> Void)) {
        GogoLogger.instance.logger.info("fetching damage relations")
        
        guard let damageRelations = damageRelations else {
            callback(nil)
            return
        }
        
        var noDamageTo: [TypeInfo]?
        var halfDamageTo: [TypeInfo]?
        var doubleDamageTo: [TypeInfo]?
        var noDamageFrom: [TypeInfo]?
        var halfDamageFrom: [TypeInfo]?
        var doubleDamageFrom: [TypeInfo]?
        
        func checkFetchFinish() {
            if noDamageTo != nil && halfDamageTo != nil && doubleDamageTo != nil &&
                noDamageFrom != nil && halfDamageFrom != nil && doubleDamageFrom != nil {
                GogoLogger.instance.logger.info("fetching damage relations finished")
                callback([noDamageTo!, halfDamageTo!, doubleDamageTo!, noDamageFrom!, halfDamageFrom!, doubleDamageFrom!])
            }
        }
        
        fetchTypeInfo(list: damageRelations.noDamageTo) { typeInfos in
            noDamageTo = typeInfos
            checkFetchFinish()
        }
        
        fetchTypeInfo(list: damageRelations.halfDamageTo) { typeInfos in
            halfDamageTo = typeInfos
            checkFetchFinish()
        }
        
        fetchTypeInfo(list: damageRelations.doubleDamageTo) { typeInfos in
            doubleDamageTo = typeInfos
            checkFetchFinish()
        }
        
        fetchTypeInfo(list: damageRelations.noDamageFrom) { typeInfos in
            noDamageFrom = typeInfos
            checkFetchFinish()
        }
        
        fetchTypeInfo(list: damageRelations.halfDamageFrom) { typeInfos in
            halfDamageFrom = typeInfos
            checkFetchFinish()
        }
        
        fetchTypeInfo(list: damageRelations.doubleDamageFrom) { typeInfos in
            doubleDamageFrom = typeInfos
            checkFetchFinish()
        }
    }
}
