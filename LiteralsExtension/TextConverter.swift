import Foundation

protocol TextConverter {
    func convert(text: String, in range: NSRange) -> String
}
