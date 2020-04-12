import Foundation
import XcodeKit

enum TextConverterError: Error {
    case notSwiftLanguage
}

extension TextConverter {
    func convert(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void) {

        let supportedContentTypes = ["public.swift-source", "com.apple.dt.playground"]
        guard supportedContentTypes.contains(invocation.buffer.contentUTI) else {
            return completionHandler(TextConverterError.notSwiftLanguage)
        }

        for selection in invocation.selections.reversed() {
            let linesSet = IndexSet(selection.start.line...selection.end.line)

            let lines = invocation[linesAt: linesSet]
            let code = lines.joined()

            let tailLength = invocation[lineAt: selection.end.line].nsLength - selection.end.column

            let changedCode = convert(text: code,
                                      in: NSRange(location: selection.start.column, length: code.nsLength - tailLength - selection.start.column))

            let changedLines = changedCode.lines
            invocation.buffer.lines.replaceObjects(in: NSRange(location: selection.start.line, length: linesSet.count),
                                                   withObjectsFrom: changedLines,
                                                   range: NSRange(location: 0, length: changedLines.count))
        }

        completionHandler(nil)
    }
}

private extension XCSourceEditorCommandInvocation {
    var selections: [XCSourceTextRange] {
        let selections = buffer.selections.compactMap { $0 as? XCSourceTextRange }

        if selections.isEmpty {
            return [bufferRange]
        }

        if selections.count == 1, let selection = selections.first, selection.start == selection.end {
            return [bufferRange]
        }

        return selections
    }

    subscript(linesAt indexSet: IndexSet) -> [String] {
        return buffer.lines.objects(at: indexSet).map { $0 as! String }
    }

    subscript(lineAt index: Int) -> String {
        return buffer.lines[index] as! String
    }

    private var bufferRange: XCSourceTextRange {
        let start = XCSourceTextPosition(line: 0, column: 0)
        let end = XCSourceTextPosition(line: buffer.lines.count - 1, column: lastLine.nsLength)
        return XCSourceTextRange(start: start, end: end)
    }

    private var lastLine: String {
        return buffer.lines.lastObject! as! String
    }
}

extension XCSourceTextPosition: Equatable {
    public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        return lhs.line == rhs.line && lhs.column == rhs.column
    }
}

private extension String {
    var nsLength: Int {
        return (self as NSString).length
    }

    var lines: [String] {
        let lines = components(separatedBy: "\n").map { $0 + "\n" }
        if hasSuffix("\n") {
            return Array(lines.dropLast())
        }
        return lines
    }
}
