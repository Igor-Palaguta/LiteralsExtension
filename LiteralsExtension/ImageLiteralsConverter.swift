import Foundation

struct ImageLiteralsConverter: TextConverter {
   func convert(text: String, in range: NSRange) -> String {
      var result = text as NSString

      let matches = imageRegex.matches(in: text,
                                       options: [],
                                       range: range)

      for match in matches.reversed() {
         var name = result.substring(with: match.rangeAt(1))
         let pathExtension = (name as NSString).pathExtension
         if pathExtension.isEmpty {
            name = name + ".png"
         }
         result = result.replacingCharacters(in: match.range, with: "#imageLiteral(resourceName: \"\(name)\")") as NSString
      }
      return result as String
   }
}

fileprivate let imageRegex: NSRegularExpression = {
   let pattern = "(?:UIImage(?:\\.init)?)\\(\\s*named:\\s*\"(.+?)\"\\s*\\)"
   return try! NSRegularExpression(pattern: pattern, options: [])
}()
