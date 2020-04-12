import Foundation
import XcodeKit

final class ColorLiteralsCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let converter = ColorLiteralsConverter()
        converter.convert(with: invocation, completionHandler: completionHandler)
    }
}
