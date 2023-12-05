//
//  PokemonAPITests.swift
//  GogoPokeTests
//
//  Created by Connie Chang on 2023/12/5.
//

import XCTest
@testable import GogoPoke

final class PokemonAPITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchPokemonList() {
        PokeManager.fetchPokemonList(reload: true) { error in
            if case _ = error {
                XCTFail("testFetchPokemon failed")
            }
            XCTAssertTrue(PokeManager.instance.pokemonInfos.isEmpty, "testFetchPokemonList failed")
        }
    }
    
    func testFetchPokemon() {
        PokeManager.fetchPokemon(id: 1) { pokemon, pokemonInfo, error in
            if case _ = error {
                XCTFail("testFetchPokemon failed")
            }
        }
    }
    
    func testFetchTypeList() {
        TypeManager.fetchTypeList { error in
            if case _ = error {
                XCTFail("testFetchTypeList failed")
            }
            XCTAssertTrue(TypeManager.instance.typeInfos.isEmpty, "testFetchTypeList failed")
        }
    }
    
    func testFetchType() {
        TypeManager.fetchType(id: 1) { type, error in
            if case _ = error {
                XCTFail("testFetchType failed")
            }
        }
    }

}
