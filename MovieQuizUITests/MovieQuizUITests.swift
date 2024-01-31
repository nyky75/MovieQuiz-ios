import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    var yesButton: XCUIElement!
    var noButton: XCUIElement!

    override func setUpWithError() throws {
        try super.setUpWithError()
                
        app = XCUIApplication()
        app.launch()
        yesButton = app.buttons["Yes"]
        noButton = app.buttons["No"]
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false  
    }

    override func tearDownWithError() throws {
            try super.tearDownWithError()
            
            app.terminate()
            app = nil
        }

    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
       yesButton.tap() // находим кнопку `Да` и нажимаем её
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation// ещё раз находим постер
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        noButton.tap() // находим кнопку `Да` и нажимаем её
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation// ещё раз находим постер
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testLabelchangesAfterYes() {
        sleep(3)
        let firstQuestionLabelText = app.staticTexts["Index"]
        
        yesButton.tap()
        sleep(3)
        XCTAssertEqual(firstQuestionLabelText.label, "2/10")
    }

    func testLabelchangesAfterNo() {
        sleep(3)
        let firstQuestionLabelText = app.staticTexts["Index"]
        
        noButton.tap()
        sleep(3)
        XCTAssertEqual(firstQuestionLabelText.label, "2/10")
    }
    
    func testAlertAppearsAtEndGame() {
        sleep(3)
        for _ in 1...10 {
            yesButton.tap()
            sleep(2)
        }
        let alert = app.alerts["Этот раунд закончен!"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд закончен!")
        XCTAssertEqual("Сыграть ещё раз", alert.buttons.firstMatch.label)
    }
    
    func testAlertDisappearsAfterRestart() {
        sleep(3)
        for _ in 1...10 {
            noButton.tap()
            sleep(2)
        }
        let alert = app.alerts["Этот раунд закончен!"]
        alert.scrollViews.otherElements.buttons["Сыграть ещё раз"].tap()
        
        sleep(2)
        XCTAssertFalse(alert.exists)
        let firstQuestionLabelText = app.staticTexts["Index"]
        print(firstQuestionLabelText)
        XCTAssertEqual(firstQuestionLabelText.label, "1/10")
    }
}
