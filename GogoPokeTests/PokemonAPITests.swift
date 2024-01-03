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
        let expectation = expectation(description: "testFetchPokemonList")
        
        PokeManager.fetchPokemonList(reload: true) { error in
            if let _ = error {
                XCTFail("testFetchPokemonList failed")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchPokemon() {
        let expectation = expectation(description: "testFetchPokemon")
        
        PokeManager.fetchPokemon(id: 1) { pokemon, pokemonInfo, error in
            if let _ = error {
                XCTFail("testFetchPokemon failed")
            }
            XCTAssertFalse(pokemon == nil, "testFetchPokemon failed")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchTypeList() {
        let expectation = expectation(description: "testFetchTypeList")
        
        TypeManager.fetchTypeList { error in
            if let _ = error {
                XCTFail("testFetchTypeList failed")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchType() {
        let expectation = expectation(description: "testFetchTypeList")
        
        TypeManager.fetchType(id: 1) { type, error in
            if let _ = error {
                XCTFail("testFetchTypeList failed")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

}
