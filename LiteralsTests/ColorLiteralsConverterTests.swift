import XCTest

final class ColorLiteralsConverterTests: XCTestCase {
    private let converter = ColorLiteralsConverter()

    private func convert(_ text: String, in range: NSRange? = nil) -> String {
        return converter.convert(text: text, in: range ?? NSRange(location: 0, length: (text as NSString).length))
    }

    func testUIColor() {
        XCTAssertEqual(convert("UIColor(red: 1, green: 0, blue: 0, alpha: 1)"), "#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)")
    }

    func testNSColor() {
        XCTAssertEqual(convert("NSColor(red: 1, green: 1, blue: 0, alpha: 1)"), "#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)")
    }

    func testExplicitInit() {
        XCTAssertEqual(convert("NSColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)"), "#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)")
        XCTAssertEqual(convert("UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)"), "#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)")
    }

    func testMultilineConvert() {
        XCTAssertEqual(convert("UIColor(red: 1,\ngreen: 0,\nblue: 0,\nalpha: 1)"), "#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)")
        XCTAssertEqual(convert("UIColor(red: 1, green: 0, blue: 0, alpha: 1)\nNSColor(red: 1, green: 1, blue: 0, alpha: 1)"), "#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)\n#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)")
    }

    func testLeadingSpace() {
        XCTAssertEqual(convert("NSColor( red: 1, green: 0, blue: 0, alpha: 1)"), "#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)")
    }

    func testRange() {
        XCTAssertEqual(convert("UIColor(red: 1, green: 0, blue: 0, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1)", in: NSRange(location: 46, length: 44)), "UIColor(red: 1, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)")
        XCTAssertEqual(convert("UIColor(red: 1, green: 0, blue: 0, alpha: 1)", in: NSRange(location: 1, length: 43)), "UIColor(red: 1, green: 0, blue: 0, alpha: 1)")
    }

    func testDivision() {
        XCTAssertEqual(
            convert("UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)"),
            "#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)"
        )

        XCTAssertEqual(
            convert("UIColor(red: 5 / 255, green: 0, blue: 0, alpha: 1)"),
            "#colorLiteral(red: 0.02, green: 0, blue: 0, alpha: 1)"
        )
    }
}
