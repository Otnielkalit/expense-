//
//  AmountParser.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation

enum AmountParser {
    private static let numberPattern = #"(\d[\d.,]*)"#

    private static let regex = try! NSRegularExpression(
        pattern: numberPattern,
        options: []
    )
    static func parse(from text: String) -> (amount: Double, cleaned: String) {
        let nsRange = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: nsRange),
              let range = Range(match.range(at: 1), in: text)
        else {
            return (0, text)
        }

        let numberString = String(text[range])
        let number = normalize(numberString)
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
