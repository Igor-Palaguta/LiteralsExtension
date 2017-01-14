import Foundation
import XcodeKit

enum ConverterError: Error {
   case notSwiftLanguage
   case noSelection
}

final class ColorLiteralsCommand: NSObject, XCSourceEditorCommand {
   func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
      let converter = ColorLiteralsConverter()
      converter.convert(with: invocation, completionHandler: completionHandler)
   }
}

extension TextConverter {
   fileprivate func convert(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
      let supportedContentTypes = ["public.swift-source", "com.apple.dt.playground"]
      guard supportedContentTypes.contains(invocation.buffer.contentUTI) else {
         return completionHandler(ConverterError.notSwiftLanguage)
      }

      guard let  selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
         completionHandler(ConverterError.noSelection)
         return
      }

      let linesSet = selection.start == selection.end
         ? IndexSet(0...invocation.buffer.lines.count-1)
         : IndexSet(selection.start.line...selection.end.line)

      let affectedLines = invocation.buffer.lines.objects(at: linesSet) as! [String]

      let unusedWhitespaces = "\r\n"
      let changedCode = self.convert(text: affectedLines.joined(separator: unusedWhitespaces))

      invocation.buffer.lines.replaceObjects(at: linesSet,
                                             with: changedCode.components(separatedBy: unusedWhitespaces))
      
      completionHandler(nil)
   }
}

extension XCSourceTextPosition: Equatable {
   public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
      return lhs.line == rhs.line && lhs.column == rhs.column
   }
}
