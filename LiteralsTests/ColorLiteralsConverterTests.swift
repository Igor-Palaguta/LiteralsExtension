import XCTest

final class ColorLiteralsConverterTests: XCTestCase {
   private let converter = ColorLiteralsConverter()

   private func convert(_ text: String) -> String {
      return converter.convert(text: text)
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
}
