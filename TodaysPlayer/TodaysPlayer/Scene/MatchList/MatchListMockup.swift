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
        matchId: 1,
        matchType: .futsal,
        applyStatus: .accepted,
        matchLocation: "강남 논현동 풋살장",
        matchTitle: "주말 오전 2파전 (11명째 모십니다!)",
        matchTime: "10:00~12:00",
        applyCount: 11,
        maxCount: 12,
        matchFee: 5000,
        genderLimit: "남성",
        levelLimit: "중급",
        imageURL: "url_001",
        postUserName: "용헌",
        rejectionReason: "",
        matchDescription: "안녕하세요! 주말 오전에 가볍게 2파전 하실 분 모집합니다. 현재 11명이고 1명만 더 오시면 바로 시작합니다!"
    ),
    
    // 2. 축구 - 여유 (10/20)
    MatchInfo(
        matchId: 2,
        matchType: .soccer,
        applyStatus: .accepted,
        matchLocation: "분당 탄천 운동장",
        matchTitle: "성남 지역 친선 축구 경기",
        matchTime: "14:00~16:00",
        applyCount: 10,
        maxCount: 20,
        matchFee: 4000,
        genderLimit: "무관",
        levelLimit: "중급",
        imageURL: "url_002",
        postUserName: "캡틴 박",
        rejectionReason: "",
        matchDescription: "분당 탄천에서 친선 축구 경기 하실 분들 모집합니다! 실력보다는 즐겁게 하는 것이 목표입니다. 초보자도 환영해요~"
    ),
    
    // 3. 풋살 - 꽉 참 (12/12) - 너만 오면 GO
    MatchInfo(
        matchId: 3,
        matchType: .futsal,
        applyStatus: .accepted,
        matchLocation: "수원 매탄동 실내 구장",
        matchTitle: "오늘 저녁 급 벙개 풋살",
        matchTime: "20:00~22:00",
        applyCount: 12,
        maxCount: 12,
        matchFee: 6000,
        genderLimit: "남성",
        levelLimit: "무관",
        imageURL: "url_003",
        postUserName: "이매치성사",
        rejectionReason: "",
        matchDescription: "갑자기 시간이 생겨서 급하게 모집합니다! 12명 다 모였으니 바로 시작할 수 있어요. 편하게 오세요!"
    ),
    
    // 4. 축구 - 신청 대기 중 (5/22)
    MatchInfo(
        matchId: 4,
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
        postUserName: "운동합시다",
        rejectionReason: "",
        matchDescription: "매주 토요일 오전 정기 모임입니다. 초급자 위주로 진행되니 부담없이 신청해주세요. 축구 처음 하시는 분도 대환영!"
    ),
    
    // 5. 풋살 - 저가 (8/10)
    MatchInfo(
        matchId: 5,
        matchType: .futsal,
        applyStatus: .accepted,
        matchLocation: "용인 기흥구 풋살장",
        matchTitle: "저렴한 구장비, 2시간 빡겜!",
        matchTime: "18:00~20:00",
        applyCount: 8,
        maxCount: 10,
        matchFee: 3000,
        genderLimit: "남성",
        levelLimit: "상급",
        imageURL: "url_005",
        postUserName: "저가매치",
        rejectionReason: "",
        matchDescription: "구장비가 저렴한 곳이라 참가비도 저렴합니다! 실력자 위주로 2시간 동안 빡세게 뛸 예정이니 체력 준비 단단히 하고 오세요."
    ),
    
    // 6. 축구 - 여성 한정 (2/18)
    MatchInfo(
        matchId: 6,
        matchType: .soccer,
        applyStatus: .accepted,
        matchLocation: "서울 잠원 지구",
        matchTitle: "여성 축구팀 연습 경기",
        matchTime: "16:00~18:00",
        applyCount: 2,
        maxCount: 18,
        matchFee: 5000,
        genderLimit: "여성",
        levelLimit: "무관",
        imageURL: "url_006",
        postUserName: "골때리는 그녀들",
        rejectionReason: "",
        matchDescription: "여성 축구팀 정기 연습 경기입니다. 축구에 관심 있는 여성분들 모두 환영합니다! 같이 즐겁게 운동해요."
    ),
    
    // 7. 풋살 - 마감 임박 (9/10)
    MatchInfo(
        matchId: 7,
        matchType: .futsal,
        applyStatus: .accepted,
        matchLocation: "인천 연수구 옥상 구장",
        matchTitle: "인천 지역 주중 풋살",
        matchTime: "07:00~09:00",
        applyCount: 9,
        maxCount: 10,
        matchFee: 4500,
        genderLimit: "무관",
        levelLimit: "초급",
        imageURL: "url_007",
        postUserName: "얼리버드",
        rejectionReason: "",
        matchDescription: "출근 전 아침 풋살! 상쾌하게 운동하고 하루를 시작해요. 초급자 위주라 부담없이 참여 가능합니다."
    ),
    
    // 8. 축구 - 레벨 상급 (15/22)
    MatchInfo(
        matchId: 8,
        matchType: .soccer,
        applyStatus: .accepted,
        matchLocation: "파주 NFC 근처",
        matchTitle: "실력자만! 상급 매치",
        matchTime: "13:00~16:00",
        applyCount: 15,
        maxCount: 22,
        matchFee: 7000,
        genderLimit: "남성",
        levelLimit: "상급",
        imageURL: "url_008",
        postUserName: "프로테스터",
        rejectionReason: "",
        matchDescription: "상급자 위주 매치입니다. 아마추어 리그 경험자 또는 그에 준하는 실력을 가진 분들만 신청 부탁드립니다. 수준 높은 경기 기대합니다!"
    ),
    
    // 9. 풋살 - 너만 오면 GO (10/10)
    MatchInfo(
        matchId: 9,
        matchType: .futsal,
        applyStatus: .accepted,
        matchLocation: "부산 해운대구 실내 구장",
        matchTitle: "지금 바로 10명 풀방!",
        matchTime: "19:00~21:00",
        applyCount: 10,
        maxCount: 10,
        matchFee: 5500,
        genderLimit: "무관",
        levelLimit: "중급",
        imageURL: "url_009",
        postUserName: "부산싸나이",
        rejectionReason: "",
        matchDescription: "부산 해운대에서 풋살 하실 분! 10명 다 찼으니 바로 시작합니다. 중급 정도 실력이면 재밌게 할 수 있어요!"
    ),
    
    // 10. 축구 - 취소됨/모집 미달 (1/20)
    MatchInfo(
        matchId: 10,
        matchType: .soccer,
        applyStatus: .rejected,
        matchLocation: "대구 수성구 스타디움",
        matchTitle: "평일 저녁 가볍게 즐길 팀 모집",
        matchTime: "19:30~21:30",
        applyCount: 1,
        maxCount: 20,
        matchFee: 4000,
        genderLimit: "무관",
        levelLimit: "초급",
        imageURL: "url_010",
        postUserName: "용병대모집",
        rejectionReason: "거절했어요",
        matchDescription: "평일 저녁에 가볍게 축구 하실 분들 모집합니다. 부담없이 와서 운동하고 가세요!"
    )
]
