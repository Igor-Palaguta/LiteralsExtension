import Foundation

struct ColorLiteralsConverter: TextConverter {
   func convert(text: String, in range: NSRange) -> String {
      var result = text as NSString

      let matches = rgbaColorRegex.matches(in: text,
                                           options: [],
                                           range: range)

      for match in matches.reversed() {
         let components = [
            ("red", result.substring(with: match.rangeAt(1))),
            ("green", result.substring(with: match.rangeAt(2))),
            ("blue", result.substring(with: match.rangeAt(3))),
            ("alpha", result.substring(with: match.rangeAt(4)))
            ]
            .map { "\($0): \($1.evaluate())" }
            .joined(separator: ", ")
         result = result.replacingCharacters(in: match.range, with: "#colorLiteral(\(components))") as NSString
      }

      return result as String
   }
}

fileprivate let rgbaColorRegex: NSRegularExpression = {
   let componentFormat = "%@:\\s*((?:[\\d\\.]+(?:\\s*/\\s*[\\d\\.]+)?))"
   let rgba = ["red", "green", "blue", "alpha"]
   let rgbaPattern = rgba
      .map { String(format: componentFormat, $0) }
      .joined(separator: "\\s*,\\s*")

   let pattern = "(?:(?:UI|NS)Color(?:\\.init)?)\\(\\s*\(rgbaPattern)\\s*\\)"

   return try! NSRegularExpression(pattern: pattern, options: [])
}()

private let formatter: NumberFormatter = {
   let formatter = NumberFormatter()
   formatter.minimumIntegerDigits = 1
   formatter.maximumFractionDigits = 3
   return formatter
}()

private extension String {
   func evaluate() -> String {
      guard self.contains("/") else {
         return self
      }

      //1.0 casts expression to float
      //e.g: 5 / 10 = 0, but 1.0 * 5 / 10 = 0.5
      let expression = NSExpression(format: "1.0 * \(self)")
      guard let result = expression.expressionValue(with: nil, context: nil) as? NSNumber,
         let formattedResult = formatter.string(from: result) else {
         return self
      }
      return formattedResult
   }
}
