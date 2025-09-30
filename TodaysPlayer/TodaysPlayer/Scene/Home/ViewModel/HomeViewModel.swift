//
//  HomeViewModel.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI
import Observation

@Observable
class HomeViewModel {
    // 개발용 사용자 ID
    private static let STATIC_USER_ID = "bJYjlQZuaqvw2FDB5uNa"
    
    // 배너 관련
    var currentBannerIndex = 0
    private var bannerTimer: Timer?
    
    // 데이터 관련
    var matches: [Match] = []
    var user: User?
    var regions: [RegionData] = []
    var appliedMatchIds: Set<String> = [] // 사용자가 신청한 매치 ID들
    
    
    // 로딩 상태
    var isLoading = false
    var errorMessage: String?
    
    // FirestoreManager 사용
    private let firestore = FirestoreManager.shared
    
    // 배너 데이터
    let bannerData = [
        BannerItem(discountTag: "30% OFF", imageName: "HomeBanner1"),
        BannerItem(discountTag: "20% off", imageName: "HomeBanner2")
    ]
    
    
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    
    @MainActor
    func loadInitialData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        // 초기화
        self.matches = []
        self.user = nil
        self.regions = []
        
        do {
            print("Firebase에서 데이터 로딩 시작...")
            // 사용자를 먼저 로드
            try await self.loadCurrentUser()
            
            // 나머지 데이터를 병렬로 로드
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { try await self.loadMatches() }
                group.addTask { try await self.loadAppliedMatches() }
                group.addTask { try await self.loadRegions() }
                
                // 모든 작업 완료 대기
                try await group.waitForAll()
            }
            
            print("Firebase 데이터 로딩 완료!")
        } catch {
            print("Firebase 데이터 로딩 실패: \(error.localizedDescription)")
            
            // Firebase 로딩 실패 시 빈 데이터 사용
            self.matches = []
            self.user = nil
            self.regions = []
        }
        
        self.isLoading = false
    }
    
    func loadMatches() async throws {
        print("매치 데이터 로딩 중...")
        
        let loadedMatches = try await firestore.queryDocuments(collection: "matches", where: "status", isEqualTo: "recruiting", as: Match.self)
        print("Firebase에서 로드된 매치 수: \(loadedMatches.count)개")
        
        // 중복 제거 (ID 기준) - 비어있는 ID 필터링
        let validMatches = loadedMatches.filter { !$0.id.isEmpty }
        let uniqueMatches = Array(Set(validMatches.map { $0.id }).compactMap { id in
            validMatches.first { $0.id == id }
        })
        
        print("유효한 매치 수: \(validMatches.count)개")
        print("중복 제거 후 매치 수: \(uniqueMatches.count)개")
        
        // 매치 정보 출력
        for (index, match) in uniqueMatches.enumerated() {
            print("매치 \(index + 1): \(match.title) - \(match.location.name)")
        }
        
        await MainActor.run {
            self.matches = uniqueMatches
        }
        
        print("매치 데이터 로딩 완료: \(uniqueMatches.count)개 (중복 제거 후)")
    }
    
    func loadAppliedMatches() async throws {
        guard let currentUser = user else {
            print("사용자가 없어서 신청한 매치 로딩 건너뜀")
            
            await MainActor.run {
                self.appliedMatchIds = []
            }
            
            return
        }
        
        print("신청한 매치 데이터 로딩 중... (userId: \(currentUser.id))")
        
        do {
            // 매치에서 현재 사용자가 참가자로 등록된 매치 ID들 가져오기
            let allMatches = try await firestore.getDocuments(collection: "matches", as: Match.self)
            let appliedMatchIds = Set(allMatches.compactMap { match in
                // participants에 현재 사용자 ID가 있으면 해당 매치 ID 반환
                match.participants.keys.contains(currentUser.id) ? match.id : nil
            })
            
            await MainActor.run {
                self.appliedMatchIds = appliedMatchIds
            }
            
            print("신청한 매치 데이터 로딩 완료: \(appliedMatchIds.count)개")
        } catch {
            print("신청한 매치 데이터 로딩 실패: \(error)")
            
            await MainActor.run {
                self.appliedMatchIds = []
            }
        }
    }
    
    func loadCurrentUser() async throws {
        print("사용자 데이터 로딩 중...")
        
        do {
            // 개발용 사용자 ID로 사용자 가져오기
            if let user = try await firestore.getDocument(collection: "users", documentId: Self.STATIC_USER_ID, as: User.self) {
                await MainActor.run {
                    self.user = user
                }
                
                print("사용자 데이터 로딩 완료: \(user.displayName) (ID: \(user.id))")
            } else {
                print("사용자 ID \(Self.STATIC_USER_ID)를 찾을 수 없음")
                
                // 개발용 사용자가 없으면 첫 번째 사용자 사용
                let users = try await firestore.getDocuments(collection: "users", as: User.self)
                
                await MainActor.run {
                    self.user = users.first
                }
                
                print("첫 번째 사용자 데이터 로딩 완료: \(users.first?.displayName ?? "없음")")
            }
        } catch {
            print("사용자 데이터 로딩 실패: \(error)")
            
            throw error
        }
    }
    
    func loadRegions() async throws {
        print("지역 데이터 로딩 중...")
        
        let loadedRegions = try await firestore.queryDocuments(collection: "regions", where: "parentRegion", isEqualTo: NSNull(), as: RegionData.self)
        
        await MainActor.run {
            self.regions = loadedRegions
        }
        
        print("지역 데이터 로딩 완료: \(loadedRegions.count)개")
    }

    func getNextMatch() -> Match? {
        // 다음 경기 가져오기 (사용자가 참가한 매치 중 가장 가까운 미래 매치)
        
        guard let currentUser = user else { return nil }
        
        let now = Date()
        
        return matches.filter { match in
            // 사용자가 참가한 매치 && 미래 매치
            match.participants.keys.contains(currentUser.id) && match.dateTime > now
        }
        .sorted { $0.dateTime < $1.dateTime }
        .first
    }

    func getNearbyMatches(limit: Int = 3) -> [Match] {
        // 사용자 위치 기준으로 가까운 매치들을 거리순으로 정렬하여 반환 (최대 3개)

        guard !matches.isEmpty else { return [] }
        
        let now = Date()
        let availableMatches = matches.filter { match in
            // 이미 신청한 매치 제외 && 미래 매치
            !appliedMatchIds.contains(match.id) && match.dateTime > now
        }
        
        // 거리순으로 정렬 (가까운 순)
        let sortedMatches = availableMatches.sorted { match1, match2 in
            let distance1 = calculateDistanceValue(to: match1.location.coordinates)
            let distance2 = calculateDistanceValue(to: match2.location.coordinates)
            
            return distance1 < distance2
        }
        
        return Array(sortedMatches.prefix(limit))
    }
    
    private func calculateDistanceValue(to coordinates: Coordinates) -> Double {
        // 두 좌표 간의 거리 계산 (km)
        
        let userLatitude = 37.5665  // 서울시청 근처 (실제로는 사용자 위치 사용)
        let userLongitude = 126.9780
        
        return calculateDistanceBetweenCoordinates(
            lat1: userLatitude, lon1: userLongitude,
            lat2: coordinates.latitude, lon2: coordinates.longitude
        )
    }
    
    func formatDistance(to coordinates: Coordinates) -> String {
        // 거리를 문자열로 포맷팅
        
        let distance = calculateDistanceValue(to: coordinates)
        
        if distance < 1.0 {
            return String(format: "%.1fkm", distance)
        } else {
            return String(format: "%.0fkm", distance)
        }
    }
    
    /// Haversine 공식을 사용한 두 좌표 간 거리 계산
    private func calculateDistanceBetweenCoordinates(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0 // 지구 반지름 (km)
        
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        
        let a = sin(dLat/2) * sin(dLat/2) +
        cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
        sin(dLon/2) * sin(dLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadius * c
    }
}
