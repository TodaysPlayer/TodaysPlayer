//
//  MatchListMockup.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import Foundation

// MARK: - 목업 데이터 10개

let mockMatchData: [MatchInfo] = [
    // 1. 풋살 - 마감 임박 (11/12)
    MatchInfo(
        matchId: "M001",
        matchType: .futsal,
        applyStatus: .confirmed,
        matchLocation: "강남 논현동 풋살장",
        matchTitle: "주말 오전 2파전 (11명째 모십니다!)",
        matchTime: "10:00~12:00",
        applyCount: 11,
        maxCount: 12,
        matchFee: 5000,
        genderLimit: "남성",
        levelLimit: "초/중급",
        imageURL: "url_001",
        postUserName: "축구왕 슛돌이"
    ),
    
    // 2. 축구 - 여유 (10/20)
    MatchInfo(
        matchId: "M002",
        matchType: .soccer,
        applyStatus: .confirmed,
        matchLocation: "분당 탄천 운동장",
        matchTitle: "성남 지역 친선 축구 경기",
        matchTime: "14:00~16:00",
        applyCount: 10,
        maxCount: 20,
        matchFee: 4000,
        genderLimit: "무관",
        levelLimit: "중급",
        imageURL: "url_002",
        postUserName: "캡틴 박"
    ),
    
    // 3. 풋살 - 꽉 참 (12/12) - 너만 오면 GO
    MatchInfo(
        matchId: "M003",
        matchType: .futsal,
        applyStatus: .confirmed,
        matchLocation: "수원 매탄동 실내 구장",
        matchTitle: "오늘 저녁 급 벙개 풋살",
        matchTime: "20:00~22:00",
        applyCount: 12,
        maxCount: 12,
        matchFee: 6000,
        genderLimit: "남성",
        levelLimit: "무관",
        imageURL: "url_003",
        postUserName: "이매치성사"
    ),
    
    // 4. 축구 - 신청 대기 중 (5/22)
    MatchInfo(
        matchId: "M004",
        matchType: .soccer,
        applyStatus: .standby,
        matchLocation: "고양 종합 운동장",
        matchTitle: "토요일 오전 정기 구장",
        matchTime: "09:00~12:00",
        applyCount: 5,
        maxCount: 22,
        matchFee: 3500,
        genderLimit: "남성",
        levelLimit: "초급",
        imageURL: "url_004",
        postUserName: "운동합시다"
    ),
    
    // 5. 풋살 - 저가 (8/10)
    MatchInfo(
        matchId: "M005",
        matchType: .futsal,
        applyStatus: .confirmed,
        matchLocation: "용인 기흥구 풋살장",
        matchTitle: "저렴한 구장비, 2시간 빡겜!",
        matchTime: "18:00~20:00",
        applyCount: 8,
        maxCount: 10,
        matchFee: 3000,
        genderLimit: "남성",
        levelLimit: "중/상급",
        imageURL: "url_005",
        postUserName: "저가매치"
    ),
    
    // 6. 축구 - 여성 한정 (2/18)
    MatchInfo(
        matchId: "M006",
        matchType: .soccer,
        applyStatus: .confirmed,
        matchLocation: "서울 잠원 지구",
        matchTitle: "여성 축구팀 연습 경기",
        matchTime: "16:00~18:00",
        applyCount: 2,
        maxCount: 18,
        matchFee: 5000,
        genderLimit: "여성",
        levelLimit: "무관",
        imageURL: "url_006",
        postUserName: "골때리는 그녀들"
    ),
    
    // 7. 풋살 - 마감 임박 (9/10)
    MatchInfo(
        matchId: "M007",
        matchType: .futsal,
        applyStatus: .confirmed,
        matchLocation: "인천 연수구 옥상 구장",
        matchTitle: "인천 지역 주중 풋살",
        matchTime: "07:00~09:00",
        applyCount: 9,
        maxCount: 10,
        matchFee: 4500,
        genderLimit: "무관",
        levelLimit: "초급",
        imageURL: "url_007",
        postUserName: "얼리버드"
    ),
    
    // 8. 축구 - 레벨 상급 (15/22)
    MatchInfo(
        matchId: "M008",
        matchType: .soccer,
        applyStatus: .confirmed,
        matchLocation: "파주 NFC 근처",
        matchTitle: "실력자만! 상급 매치",
        matchTime: "13:00~16:00",
        applyCount: 15,
        maxCount: 22,
        matchFee: 7000,
        genderLimit: "남성",
        levelLimit: "상급",
        imageURL: "url_008",
        postUserName: "프로테스터"
    ),
    
    // 9. 풋살 - 너만 오면 GO (10/10)
    MatchInfo(
        matchId: "M009",
        matchType: .futsal,
        applyStatus: .confirmed,
        matchLocation: "부산 해운대구 실내 구장",
        matchTitle: "지금 바로 10명 풀방!",
        matchTime: "19:00~21:00",
        applyCount: 10,
        maxCount: 10,
        matchFee: 5500,
        genderLimit: "무관",
        levelLimit: "중급",
        imageURL: "url_009",
        postUserName: "부산싸나이"
    ),
    
    // 10. 축구 - 취소됨/모집 미달 (1/20)
    MatchInfo(
        matchId: "M010",
        matchType: .soccer,
        applyStatus: .rejected,
        matchLocation: "대구 수성구 스타디움",
        matchTitle: "평일 저녁 가볍게 즐길 팀 모집",
        matchTime: "19:30~21:30",
        applyCount: 1,
        maxCount: 20,
        matchFee: 4000,
        genderLimit: "무관",
        levelLimit: "초/중급",
        imageURL: "url_010",
        postUserName: "용병대모집"
    )
]
