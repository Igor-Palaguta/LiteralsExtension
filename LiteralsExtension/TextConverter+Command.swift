import Foundation
import XcodeKit

enum TextConverterError: Error {
   case notSwiftLanguage
   case noSelection
}

extension TextConverter {
   func convert(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
      let supportedContentTypes = ["public.swift-source", "com.apple.dt.playground"]
      guard supportedContentTypes.contains(invocation.buffer.contentUTI) else {
         return completionHandler(TextConverterError.notSwiftLanguage)
      }

      guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
         completionHandler(TextConverterError.noSelection)
         return
      }

      let range = selection.start == selection.end ? invocation.bufferRange : selection

      let linesSet = IndexSet(range.start.line...range.end.line)

      let lines = invocation[linesAt: linesSet]
      let code = lines.joined()

      let tailLength = invocation[lineAt: range.end.line].nsLength - range.end.column

      let changedCode = self.convert(text: code,
                                     in: NSRange(location: range.start.column, length: code.nsLength - tailLength - range.start.column))

      let changedLines = changedCode.lines
      invocation.buffer.lines.replaceObjects(in: NSRange(location: range.start.line, length: linesSet.count),
                                             withObjectsFrom: changedLines,
                                             range: NSRange(location: 0, length: changedLines.count))

      completionHandler(nil)
   }
}

extension XCSourceEditorCommandInvocation {
   fileprivate var bufferRange: XCSourceTextRange {
      let start = XCSourceTextPosition(line: 0, column: 0)
      let end = XCSourceTextPosition(line: self.buffer.lines.count - 1,
                                     column: self.lastLine.nsLength)
      return XCSourceTextRange(start: start, end: end)
   }

   fileprivate subscript(linesAt indexSet: IndexSet) -> [String] {
      return self.buffer.lines.objects(at: indexSet).map { $0 as! String }
   }

   fileprivate subscript(lineAt index: Int) -> String {
      return self.buffer.lines[index] as! String
   }

   private var lastLine: String {
      return self.buffer.lines.lastObject! as! String
   }
}

extension XCSourceTextPosition: Equatable {
   public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
      return lhs.line == rhs.line && lhs.column == rhs.column
   }
}

extension String {
   fileprivate var nsLength: Int {
      return (self as NSString).length
   }

   fileprivate var lines: [String] {
      let lines = self.components(separatedBy: "\n").map { $0 + "\n" }
      if self.hasSuffix("\n") {
         return Array(lines.dropLast())
      }
      return lines
   }
}
