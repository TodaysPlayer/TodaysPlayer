//
//  GameFilter.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/25/25.
//

import Foundation

// 지역 enum 정의
enum Region: String, CaseIterable {
    case all = "전체"
    case seoul = "서울"
    case gyeonggi = "경기"
    case incheon = "인천"
    case gangwon = "강원"
    case daejeonSejong = "대전/세종"
    case chungbuk = "충북"
    case chungnam = "충남"
    case daegu = "대구"
    case busan = "부산"
    case ulsan = "울산"
    case gyeongbuk = "경북"
    case gyeongnam = "경남"
    case gwangju = "광주"
    case jeonbuk = "전북"
    case jeonnam = "전남"
    case jeju = "제주"
}

// 실력 레벨 enum
enum SkillLevel: String, CaseIterable {
    case beginner = "입문자"
    case intermediate = "초급"
    case advanced = "중급"
    case expert = "상급"
}

enum Gender: String, CaseIterable {
    case male = "남성"
    case female = "여성"
}

// 참가비 enum
enum FeeType: String, CaseIterable {
    case free = "무료"
    case paid = "유료"
}

// 필터 데이터 구조체
struct GameFilter {
    var matchType: MatchType? = nil // 단일 선택: 축구 or 풋살
    var skillLevels: Set<SkillLevel> = [] // 복수선택: 프로, 아마추어 둘 다 가능
    var gender: Gender? = nil // 단일 선택: 남자만 or 여자만
    var feeType: FeeType? = nil // 단일 선택: 무료 or 유료
    var region: Region = .all
    
    // 서버로 보낼 딕셔너리 형태로 변환
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let matchType = matchType {
            dict["matchType"] = matchType.rawValue
        }
        
        if !skillLevels.isEmpty {
            dict["levelLimits"] = skillLevels.map { $0.rawValue }  // String 배열로 변환
        }
        
        // 단일 선택 항목들은 단일 값으로 전송
        if let gender = gender {
            dict["genderLimit"] = gender.rawValue
        }
        
        if let feeType = feeType {
            dict["feeType"] = feeType.rawValue
        }
        
        return dict
    }
    
    // 필터가 비어있는지 확인
    var isEmpty: Bool {
        return matchType == nil && skillLevels.isEmpty && gender == nil && feeType == nil
    }
}
