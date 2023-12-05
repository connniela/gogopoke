//
//  GogoPokeUITestsPokemonList.swift
//  GogoPokeUITests
//
//  Created by Connie Chang on 2023/12/5.
//

import XCTest

final class GogoPokeUITestsPokemonList: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        tapPokemonListButton()
    }

    func testPokemonListButtonTappedOpensPokemonListPage() throws {
        let pokemonCell = app.cells["pokemonCell"].firstMatch
        XCTAssertTrue(pokemonCell.exists)
    }
    
    func testPokemonCellTappedOpensPokemonDetailPage() throws {
        let pokemonCell = app.cells["pokemonCell"].firstMatch
        pokemonCell.tap()
        
        sleep(2)
        
        let pokemonNameLabel = app.staticTexts["pokemonName"]
        XCTAssertTrue(pokemonNameLabel.exists)
    }
    
    func tapPokemonListButton() {
        let button = app.buttons["pokemonListButton"]
        XCTAssertTrue(button.exists)
        
        button.tap()
        
        sleep(5)
    }
}
