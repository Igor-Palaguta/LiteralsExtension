import Foundation

struct ImageLiteralsConverter: TextConverter {
    private static let imageRegex: NSRegularExpression = {
        let pattern = "(?:UIImage(?:\\.init)?)\\(\\s*named:\\s*\"(.+?)\"\\s*\\)"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    func convert(text: String, in range: NSRange) -> String {
        var result = text as NSString

        let matches = Self.imageRegex.matches(in: text,
                                              options: [],
                                              range: range)

        for match in matches.reversed() {
            let name = result.substring(with: match.range(at: 1))
            result = result.replacingCharacters(in: match.range, with: "#imageLiteral(resourceName: \"\(name)\")") as NSString
        }
        return result as String
    }
}
