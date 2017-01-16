import Foundation

struct ColorLiteralsConverter: TextConverter {
   func convert(text: String, in range: NSRange) -> String {
      var result = text as NSString

      let matches = rgbaColorRegex.matches(in: text,
                                           options: [],
                                           range: range)

      for match in matches.reversed() {

         let components: [(String, String)] = [
            ("red", result.substring(with: match.rangeAt(1))),
            ("green", result.substring(with: match.rangeAt(2))),
            ("blue", result.substring(with: match.rangeAt(3))),
            ("alpha", result.substring(with: match.rangeAt(4)))
         ]
         let formattedComponents = components.map { "\($0): \($1)" }.joined(separator: ", ")
         result = result.replacingCharacters(in: match.range, with: "#colorLiteral(\(formattedComponents))") as NSString
      }
      return result as String
   }
}

fileprivate let rgbaColorRegex: NSRegularExpression = {
   let componentFormat = "%@:\\s*([\\d\\.]+)"
   let rgba = ["red", "green", "blue", "alpha"]
   let rgbaPattern = rgba
      .map { String(format: componentFormat, $0) }
      .joined(separator: "\\s*,\\s*")

   let pattern = "(?:(?:UI|NS)Color(?:\\.init)?)\\(\\s*\(rgbaPattern)\\s*\\)"

   return try! NSRegularExpression(pattern: pattern, options: [])
}()
