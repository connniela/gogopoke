//
//  GogoPokeUITestsTypePokemon.swift
//  GogoPokeUITests
//
//  Created by Connie Chang on 2023/12/5.
//

import XCTest

final class GogoPokeUITestsTypePokemon: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        tapTypePokemonButton()
    }
    
    func testTypePokemonButtonTappedOpensTypePokemonPage() throws {
        let typeTitleLabel = app.staticTexts["typeTitleLabel"]
        XCTAssertTrue(typeTitleLabel.exists)
    }
    
    func testTypePokemonPageForSelectType() throws {
        let pickerWheels = app.pickerWheels.element(boundBy: 0)
        pickerWheels.adjust(toPickerWheelValue: "Fighting")
        
        sleep(5)
        
        let pokemonCell = app.cells["pokemonCell"].firstMatch
        XCTAssertTrue(pokemonCell.exists)
    }
    
    func tapTypePokemonButton() {
        let button = app.buttons["typePokemonButton"]
        XCTAssertTrue(button.exists)
        
        button.tap()
        
        sleep(5)
    }
}
