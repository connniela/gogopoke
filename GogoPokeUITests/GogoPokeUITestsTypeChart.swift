//
//  GogoPokeUITestsTypeChart.swift
//  GogoPokeUITests
//
//  Created by Connie Chang on 2023/12/5.
//

import XCTest

final class GogoPokeUITestsTypeChart: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        tapTypeChartButton()
    }
    
    func testTypeChartButtonTappedOpensTypeChartPage() throws {
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.exists)
    }
    
    func testTypeChartPageForSelectType1() throws {
        let pickerWheels = app.pickerWheels.element(boundBy: 0)
        pickerWheels.adjust(toPickerWheelValue: "Flying")
        
        sleep(2)
        
        let pokemonCell = app.cells["typeInfoCell"].firstMatch
        XCTAssertTrue(pokemonCell.exists)
    }
    
    func testTypeChartPageForSelectType2() throws {
        switchSegmentedControl(index: 1)
        
        sleep(2)
        
        let pickerWheels = app.pickerWheels.element(boundBy: 1)
        pickerWheels.adjust(toPickerWheelValue: "Ghost")
        
        sleep(2)
        
        let pokemonCell = app.cells["typeInfoCell"].firstMatch
        XCTAssertTrue(pokemonCell.exists)
    }
    
    func tapTypeChartButton() {
        let button = app.buttons["typeChartButton"]
        XCTAssertTrue(button.exists)
        
        button.tap()
        
        sleep(5)
    }
    
    func switchSegmentedControl(index: Int) {
        let segmentedControl = app.segmentedControls["typeSegmentedControl"]
        XCTAssertTrue(segmentedControl.exists)
        
        segmentedControl.buttons.element(boundBy: index).tap()
    }
}
