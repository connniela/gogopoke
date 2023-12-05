//
//  PokemonInfo.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/2.
//

import Foundation
import PokemonAPI

class PokemonInfo: Codable {
    
    var id: Int
    var name: String?
    var frontDefault: String?
    var frontFemale: String?
    var types: [TypeInfo]
    var names: [String: String]
    var height: Int?
    var weight: Int?
    
    init(id: Int, name: String?, frontDefault: String?, frontFemale: String?, types: [TypeInfo] = [], names: [String: String] = [:], height: Int?, weight: Int?) {
        self.id = id
        self.name = name
        self.frontDefault = frontDefault
        self.frontFemale = frontFemale
        self.types = types
        self.names = names
        self.height = height
        self.weight = weight
    }
    
    var typeNameText: String {
        var text: String = ""
        for typeInfo in types {
            let name = typeInfo.typeNameText
            if !text.isEmpty {
                text += " · "
            }
            text += name
        }
        return text
    }
    
    var pokemonNameText: String {
        let systemLocale = SystemLocaleUtil.deviceLocaleName()
        return names[systemLocale] ?? name ?? ""
    }
}

class TypeInfo: Codable {
    
    var id: Int
    var typeName: String?
    var typeNames: [String: String]
    var noDamageTo: [TypeInfo]
    var halfDamageTo: [TypeInfo]
    var doubleDamageTo: [TypeInfo]
    var noDamageFrom: [TypeInfo]
    var halfDamageFrom: [TypeInfo]
    var doubleDamageFrom: [TypeInfo]
    
    init(id: Int, typeName: String?, typeNames: [String: String] = [:], noDamageTo: [TypeInfo] = [], halfDamageTo: [TypeInfo] = [], doubleDamageTo: [TypeInfo] = [], noDamageFrom: [TypeInfo] = [], halfDamageFrom: [TypeInfo] = [], doubleDamageFrom: [TypeInfo] = []) {
        self.id = id
        self.typeName = typeName
        self.typeNames = typeNames
        self.noDamageTo = noDamageTo
        self.halfDamageTo = halfDamageTo
        self.doubleDamageTo = doubleDamageTo
        self.noDamageFrom = noDamageFrom
        self.halfDamageFrom = halfDamageFrom
        self.doubleDamageFrom = doubleDamageFrom
    }
    
    var typeNameText: String {
        let systemLocale = SystemLocaleUtil.deviceLocaleName()
        return typeNames[systemLocale] ?? typeName ?? ""
    }
}

class StatInfo: Codable {
    
    var baseStat: Int?
    var statName: String?
    var statNames: [String: String]
    
    init(baseStat: Int?, statName: String? = nil, statNames: [String: String] = [:]) {
        self.baseStat = baseStat
        self.statName = statName
        self.statNames = statNames
    }
    
    var statNameText: String {
        let systemLocale = SystemLocaleUtil.deviceLocaleName()
        return statNames[systemLocale] ?? statName ?? ""
    }
}
