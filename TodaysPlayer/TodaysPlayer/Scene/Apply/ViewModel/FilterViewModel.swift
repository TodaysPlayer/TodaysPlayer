//
//  FilterViewModel.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/14/25.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class FilterViewModel: ObservableObject {
    @Published var currentFilter = GameFilter()
    @Published var matches: [Match] = []
    @Published var isLoading = false
    
    // 선택된 날짜 (ApplyView에서 전달받음)
    var selectedDate: Date = Date()
    
    private let db = Firestore.firestore()
    
    // MARK: - enum 값 ↔ Firebase 필드값 매핑
    
    /// SkillLevel enum → Firebase 필드값 변환
    private func skillLevelToFirebase(_ skillLevel: SkillLevel) -> String {
        switch skillLevel {
        case .expert: return "expert"
        case .advanced: return "advanced"
        case .intermediate: return "intermediate"
        case .beginner: return "beginner"
        }
    }
    
    /// Gender enum → Firebase 필드값 변환
    private func genderToFirebase(_ gender: Gender) -> String {
        switch gender {
        case .male: return "male"
        case .female: return "female"
        }
    }
    
    /// MatchType enum → Firebase 필드값 변환
    private func matchTypeToFirebase(_ matchType: MatchType) -> String {
        switch matchType {
        case .futsal: return "futsal"
        case .soccer: return "soccer"
        }
    }
    
    // MARK: - 주소에서 지역 추출
    
    /// 주소 문자열에서 Region enum 추출
    private func extractRegion(from address: String) -> Region? {
        if address.hasPrefix("서울") || address.hasPrefix("서울특별시") {
            return .seoul
        }
        if address.hasPrefix("경기") || address.hasPrefix("경기도") {
            return .gyeonggi
        }
        if address.hasPrefix("인천") || address.hasPrefix("인천광역시") {
            return .incheon
        }
        if address.hasPrefix("강원") || address.hasPrefix("강원도") || address.hasPrefix("강원특별자치도") {
            return .gangwon
        }
        if address.hasPrefix("대전") || address.hasPrefix("대전광역시") || address.hasPrefix("세종") || address.hasPrefix("세종특별자치시") {
            return .daejeonSejong
        }
        if address.hasPrefix("충북") || address.hasPrefix("충청북도") {
            return .chungbuk
        }
        if address.hasPrefix("충남") || address.hasPrefix("충청남도") {
            return .chungnam
        }
        if address.hasPrefix("대구") || address.hasPrefix("대구광역시") {
            return .daegu
        }
        if address.hasPrefix("부산") || address.hasPrefix("부산광역시") {
            return .busan
        }
        if address.hasPrefix("울산") || address.hasPrefix("울산광역시") {
            return .ulsan
        }
        if address.hasPrefix("경북") || address.hasPrefix("경상북도") {
            return .gyeongbuk
        }
        if address.hasPrefix("경남") || address.hasPrefix("경상남도") {
            return .gyeongnam
        }
        if address.hasPrefix("광주") || address.hasPrefix("광주광역시") {
            return .gwangju
        }
        if address.hasPrefix("전북") || address.hasPrefix("전라북도") || address.hasPrefix("전북특별자치도") {
            return .jeonbuk
        }
        if address.hasPrefix("전남") || address.hasPrefix("전라남도") {
            return .jeonnam
        }
        if address.hasPrefix("제주") || address.hasPrefix("제주특별자치도") {
            return .jeju
        }
        
        return nil
    }
    
    // MARK: - 필터 적용 및 데이터 가져오기
    
    /// 필터를 적용하여 매치 데이터 가져오기
    func applyFilter() {
        Task {
            await fetchFilteredMatches()
        }
    }
    
    /// Firestore에서 필터링된 매치 가져오기
    private func fetchFilteredMatches() async {
        isLoading = true
        
        do {
            // 1. Firestore에서 전체 데이터 가져오기 (정렬만)
            let query: Query = db.collection("matches")
                .order(by: "createdAt", descending: true)
            
            let snapshot = try await query.getDocuments()
            let documents = snapshot.documents
            
            let fetchedMatches = documents.compactMap { doc -> Match? in
                let decoder = Firestore.Decoder()
                decoder.userInfo[Match.documentIdKey] = doc.documentID
                
                do {
                    return try doc.data(as: Match.self, decoder: decoder)
                } catch {
                    print("❌ Match 디코딩 실패: \(error)")
                    return nil
                }
            }
            
            // 2. 클라이언트에서 모든 필터 적용
            var filteredMatches = fetchedMatches
            
            // 지역 필터 (가장 먼저 적용)
            filteredMatches = filteredMatches.filter { match in
                let extractedRegion = extractRegion(from: match.location.address)
                return extractedRegion == currentFilter.region
            }
            
            // 날짜 필터
            filteredMatches = filteredMatches.filter { match in
                Calendar.current.isDate(match.dateTime, inSameDayAs: selectedDate)
            }
            
            // 경기 종류 필터
            if let matchType = currentFilter.matchType {
                let firebaseValue = matchTypeToFirebase(matchType)
                filteredMatches = filteredMatches.filter { $0.matchType == firebaseValue }
            }
            
            // 성별 필터
            if let gender = currentFilter.gender {
                let firebaseValue = genderToFirebase(gender)
                filteredMatches = filteredMatches.filter { $0.gender == firebaseValue }
            }
            
            // 참가비 필터
            if let feeType = currentFilter.feeType {
                switch feeType {
                case .free:
                    filteredMatches = filteredMatches.filter { $0.price == 0 }
                case .paid:
                    filteredMatches = filteredMatches.filter { $0.price > 0 }
                }
            }
            
            // 실력 필터
            if !currentFilter.skillLevels.isEmpty {
                let firebaseSkillLevels = currentFilter.skillLevels.map { skillLevelToFirebase($0) }
                filteredMatches = filteredMatches.filter { match in
                    firebaseSkillLevels.contains(match.skillLevel)
                }
            }
            
            self.matches = filteredMatches
            self.isLoading = false
            
            print("✅ 필터링 완료")
            print("   - 지역: \(currentFilter.region.rawValue)")
            print("   - 날짜: \(selectedDate)")
            print("   - 결과: \(self.matches.count)개")
            
        } catch {
            print("❌ Firestore 에러: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    // MARK: - 필터 관리
    
    /// 필터 초기화 (기본값 서울로 리셋)
    func resetFilter() {
        currentFilter = GameFilter() // region은 .seoul 기본값 유지
        applyFilter()
    }
    
    /// 초기 데이터 로드
    func fetchInitialMatches() {
        Task {
            await fetchFilteredMatches()
        }
    }
    
    /// 지역 변경 (외부에서 호출)
    func updateRegion(_ region: Region) {
        currentFilter.region = region
        applyFilter()
    }
}
