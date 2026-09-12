//
//  AmountParser.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation

enum AmountParser {
    private static let numberPattern = #"(?:rp\.?\s*|idr\s*)?(\d[\d.,]*)\s*(thousand|k|ribu|million|m|juta)?"#

    private static let regex = try! NSRegularExpression(
        pattern: numberPattern,
        options: .caseInsensitive
    )
    
    static func parse(from text: String) -> (amount: Double, cleaned: String) {
        let nsRange = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: nsRange),
              let range = Range(match.range(at: 1), in: text)
        else {
            return (0, text)
        }

        let numberString = String(text[range])
        var number = normalize(numberString)
        
        if match.numberOfRanges > 2, match.range(at: 2).location != NSNotFound,
           let multRange = Range(match.range(at: 2), in: text) {
            let multString = String(text[multRange]).lowercased()
            if ["thousand", "k", "ribu"].contains(multString) {
                number *= 1000
            } else if ["million", "m", "juta"].contains(multString) {
                number *= 1000000
            }
        }
        
        var cleaned = text
        if let replaceRange = Range(match.range(at: 0), in: text) {
            cleaned.removeSubrange(replaceRange)
        }

        return (number, cleaned)
    }

    private static func normalize(_ raw: String) -> Double {
        let digits = raw.replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(digits) ?? 0
    }
}
