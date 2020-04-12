import XCTest

final class ImageLiteralsConverterTests: XCTestCase {
    private let converter = ImageLiteralsConverter()

    private func convert(_ text: String, in range: NSRange? = nil) -> String {
        return converter.convert(text: text, in: range ?? NSRange(location: 0, length: (text as NSString).length))
    }

    // image literals don't work in tests, compare with strings
    private func imageLiteral(_ resourceName: String) -> String {
        return "#" + "imageLiteral(resourceName: \"\(resourceName)\")"
    }

    func testConvert() {
        XCTAssertEqual(convert("UIImage(named: \"FCDnipro.png\")"), imageLiteral("FCDnipro.png"))
    }

    func testWithoutExtension() {
        XCTAssertEqual(convert("UIImage(named: \"FCDnipro\")"), imageLiteral("FCDnipro"))
    }

    func testExplicitInit() {
        XCTAssertEqual(convert("UIImage.init(named: \"FCDnipro\")"), imageLiteral("FCDnipro"))
    }

    func testMultilineConvert() {
        XCTAssertEqual(convert("UIImage(named: \"FCDnipro\"), UIImage.init(named: \"FCBarcelona\")"), "\(imageLiteral("FCDnipro")), \(imageLiteral("FCBarcelona"))")
    }

    func testLeadingSpace() {
        XCTAssertEqual(convert("UIImage( named:  \"FCDnipro\"  )"), imageLiteral("FCDnipro"))
    }

    func testRange() {
        XCTAssertEqual(convert("UIImage(named: \"FCDnipro\"), UIImage(named: \"FCBarcelona\")", in: NSRange(location: 0, length: 26)), "\(imageLiteral("FCDnipro")), UIImage(named: \"FCBarcelona\")")
        XCTAssertEqual(convert("UIImage(named: \"FCDnipro\"), UIImage(named: \"FCBarcelona\")", in: NSRange(location: 28, length: 29)), "UIImage(named: \"FCDnipro\"), \(imageLiteral("FCBarcelona"))")
    }
}
