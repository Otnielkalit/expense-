import Foundation

enum DateParser {
    static func parse(from text: String) -> Date? {
        let lowerText = text.lowercased()
        let calendar = Calendar.current
        let today = Date()
        
        // Custom Indonesian Keywords
        if lowerText.contains("hari ini") {
            return today
        }
        if lowerText.contains("kemarin") {
            return calendar.date(byAdding: .day, value: -1, to: today)
        }
        if lowerText.contains("besok") {
            return calendar.date(byAdding: .day, value: 1, to: today)
        }
        if lowerText.contains("minggu lalu") {
            return calendar.date(byAdding: .day, value: -7, to: today)
        }
        if lowerText.contains("bulan lalu") {
            return calendar.date(byAdding: .month, value: -1, to: today)
        }
        
        // Check for "X hari lalu"
        let regex = try! NSRegularExpression(pattern: #"(\d+)\s+hari\s+lalu"#)
        if let match = regex.firstMatch(in: lowerText, range: NSRange(lowerText.startIndex..., in: lowerText)),
           let range = Range(match.range(at: 1), in: lowerText),
           let days = Int(lowerText[range]) {
            return calendar.date(byAdding: .day, value: -days, to: today)
        }
        
        // Fallback to NSDataDetector for standard dates (like "12 October 2023")
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
        
        return matches?.first?.date
    }
}
