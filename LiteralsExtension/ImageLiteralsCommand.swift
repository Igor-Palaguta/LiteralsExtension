import Foundation
import XcodeKit

final class ImageLiteralsCommand: NSObject, XCSourceEditorCommand {
   func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
      let converter = ImageLiteralsConverter()
      converter.convert(with: invocation, completionHandler: completionHandler)
   }
}
