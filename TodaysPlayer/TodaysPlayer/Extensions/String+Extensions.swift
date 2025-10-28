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
            return "입문자"
        case "intermediate":
            return "초급"
        case "advanced":
            return "중급"
        case "expert":
            return "상급"
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
    
    /// 우편번호(5자리 숫자)를 문자열에서 제거
    /// - Returns: 우편번호가 제거된 주소 문자열
    func removingPostalCode() -> String {
        var result = self
        
        // 맨 앞의 5자리 숫자 제거
        result = result.replacingOccurrences(of: "^\\d{5}\\s*", with: "", options: .regularExpression)
        
        // 맨 끝의 5자리 숫자 제거
        result = result.replacingOccurrences(of: "\\s*\\d{5}$", with: "", options: .regularExpression)
        
        // 연속된 공백 정리
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        
        return result
    }
    
    /// 주소에서 "지역 + 구/시" 형태로 추출
    func extractRegionWithDistrict() -> String {
        let address = self.removingPostalCode()
        
        // 1. 먼저 지역명 추출
        guard let region = EnumMapper.extractRegion(from: address) else {
            return address
        }
        
        // 2. 지역에 따른 간단한 이름
        let regionShortName: String
        switch region {
        case .all:
            regionShortName = "전체"
        case .seoul:
            regionShortName = "서울"
        case .gyeonggi:
            regionShortName = "경기"
        case .incheon:
            regionShortName = "인천"
        case .gangwon:
            regionShortName = "강원"
        case .daejeonSejong:
            regionShortName = "대전/세종"
        case .chungbuk:
            regionShortName = "충북"
        case .chungnam:
            regionShortName = "충남"
        case .daegu:
            regionShortName = "대구"
        case .busan:
            regionShortName = "부산"
        case .ulsan:
            regionShortName = "울산"
        case .gyeongbuk:
            regionShortName = "경북"
        case .gyeongnam:
            regionShortName = "경남"
        case .gwangju:
            regionShortName = "광주"
        case .jeonbuk:
            regionShortName = "전북"
        case .jeonnam:
            regionShortName = "전남"
        case .jeju:
            regionShortName = "제주"
        }
        
        // 3. 구/시 추출 - 여러 패턴 시도
        // 먼저 "○○구" 패턴 찾기
        let patterns = [
            "([가-힣]+구)",  // 한글 + 구
            "([가-힣]+시)",  // 한글 + 시
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: address, range: NSRange(address.startIndex..., in: address)),
               let range = Range(match.range(at: 1), in: address) {
                let district = String(address[range])
                
                // "서울특별시"나 "경기도" 같은 광역단위는 제외
                let excludeWords = ["특별시", "광역시", "특별자치도", "특별자치시"]
                if !excludeWords.contains(where: { district.contains($0) }) {
                    return "\(regionShortName) \(district)"
                }
            }
        }
        
        // 구/시를 못 찾으면 지역명만 반환
        return regionShortName
    }
}
