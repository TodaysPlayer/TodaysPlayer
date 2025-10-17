//
//  String+Extensions.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import Foundation
import SwiftUI

extension String {
    /// String 특정 부분 색상변경
    /// - Parameters:
    ///   - part: 변경할 부분
    ///   - color: 변경할 색상
    func highlighted(part: String, color: Color) -> AttributedString {
        var attr = AttributedString(self)
        if let range = attr.range(of: part) {
            attr[range].foregroundColor = color
            attr[range].font = .headline
        }
        return attr
    }
    
    /// 실력 레벨을 한국어로 변환
    /// - Returns: "beginner" → "초급", "intermediate" → "중급" 등
    func skillLevelToKorean() -> String {
        switch self.lowercased() {
        case "beginner":
            return "초급"
        case "intermediate":
            return "중급"
        case "advanced":
            return "고급"
        case "expert":
            return "전문가"
        default:
            return self
        }
    }
    
    /// 가격을 한국어 형식으로 변환
    /// - Parameter price: 가격 (Int)
    /// - Returns: "무료" 또는 "15,000원" 형식
    static func formatPrice(_ price: Int) -> String {
        if price == 0 {
            return "무료"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return "\(formatter.string(from: NSNumber(value: price)) ?? "\(price)")원"
        }
    }
}



