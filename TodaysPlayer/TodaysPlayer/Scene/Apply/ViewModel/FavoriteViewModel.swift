//
//  FavoriteViewModel.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/13/25.
//

import Foundation
import FirebaseFirestore
import Combine

/// 스크랩(찜) 기능을 관리하는 ViewModel
/// - 사용자가 스크랩한 매치 목록 관리
/// - 스크랩 추가/삭제 기능 제공
/// - 특정 매치의 스크랩 여부 확인
class FavoriteViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 현재 사용자가 스크랩한 matchId 목록
    @Published var favoritedMatchIds: Set<String> = []
    
    /// 로딩 상태
    @Published var isLoading = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Initialization
    
    init() {
        // 초기화 시 사용자의 스크랩 목록 불러오기
        fetchFavorites()
    }
    
    deinit {
        // 리스너 해제
        listener?.remove()
    }
    
    // MARK: - Public Methods
    
    /// 현재 사용자의 스크랩 목록을 실시간으로 불러오기
    func fetchFavorites() {
        let userId = AuthHelper.currentUserId
        
        // 기존 리스너가 있으면 제거
        listener?.remove()
        
        // 실시간 리스너 설정
        listener = db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Favorites 불러오기 실패: \(error.localizedDescription)")
                    self.errorMessage = "스크랩 목록을 불러올 수 없습니다."
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ Favorites 문서가 없습니다")
                    return
                }
                
                // matchId 목록 추출
                let matchIds = documents.compactMap { doc -> String? in
                    return doc.data()["matchId"] as? String
                }
                
                DispatchQueue.main.async {
                    self.favoritedMatchIds = Set(matchIds)
                    print("✅ Favorites 불러오기 완료: \(self.favoritedMatchIds.count)개")
                }
            }
    }
    
    /// 특정 매치가 스크랩되어 있는지 확인
    /// - Parameter matchId: 확인할 매치 ID
    /// - Returns: 스크랩 여부
    func isFavorited(matchId: String) -> Bool {
        return favoritedMatchIds.contains(matchId)
    }
    
    /// 스크랩 토글 (추가/삭제)
    /// - Parameters:
    ///   - matchId: 매치 ID
    ///   - organizerId: 매치 작성자 ID (본인 매치 체크용)
    func toggleFavorite(matchId: String, organizerId: String) {
        let userId = AuthHelper.currentUserId
        
        // 본인이 작성한 매치는 스크랩 불가
        guard userId != organizerId else {
            print("❌ 본인이 작성한 매치는 스크랩할 수 없습니다")
            errorMessage = "본인이 작성한 매치는 스크랩할 수 없습니다."
            return
        }
        
        if isFavorited(matchId: matchId) {
            // 이미 스크랩되어 있으면 삭제
            removeFavorite(matchId: matchId)
        } else {
            // 스크랩되어 있지 않으면 추가
            addFavorite(matchId: matchId)
        }
    }
    
    /// 스크랩 추가
    /// - Parameter matchId: 매치 ID
    private func addFavorite(matchId: String) {
        let userId = AuthHelper.currentUserId
        
        isLoading = true
        
        let favoriteData: [String: Any] = [
            "userId": userId,
            "matchId": matchId,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("favorites").addDocument(data: favoriteData) { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("❌ 스크랩 추가 실패: \(error.localizedDescription)")
                    self.errorMessage = "스크랩에 실패했습니다."
                } else {
                    print("✅ 스크랩 추가 성공: \(matchId)")
                    // 실시간 리스너가 자동으로 업데이트함
                }
            }
        }
    }
    
    /// 스크랩 삭제
    /// - Parameter matchId: 매치 ID
    private func removeFavorite(matchId: String) {
        let userId = AuthHelper.currentUserId
        
        isLoading = true
        
        // 해당 사용자의 해당 매치 스크랩 찾기
        db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .whereField("matchId", isEqualTo: matchId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ 스크랩 찾기 실패: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "스크랩 삭제에 실패했습니다."
                    }
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ 삭제할 스크랩을 찾을 수 없습니다")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                // 첫 번째 문서 삭제 (userId + matchId 조합은 유니크해야 함)
                let documentId = documents[0].documentID
                self.db.collection("favorites").document(documentId).delete { error in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        
                        if let error = error {
                            print("❌ 스크랩 삭제 실패: \(error.localizedDescription)")
                            self.errorMessage = "스크랩 삭제에 실패했습니다."
                        } else {
                            print("✅ 스크랩 삭제 성공: \(matchId)")
                            // 실시간 리스너가 자동으로 업데이트함
                        }
                    }
                }
            }
    }
    
    /// 스크랩한 매치 전체 목록 가져오기 (ScrapView에서 사용)
    /// - Parameter completion: Match 배열을 반환하는 클로저
    func fetchFavoritedMatches(completion: @escaping ([Match]) -> Void) {
        let userId = AuthHelper.currentUserId
        
        // 1. 사용자의 스크랩 목록 가져오기
        db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Favorites 불러오기 실패: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ Favorites 문서가 없습니다")
                    completion([])
                    return
                }
                
                let matchIds = documents.compactMap { $0.data()["matchId"] as? String }
                
                guard !matchIds.isEmpty else {
                    print("⚠️ 스크랩한 매치가 없습니다")
                    completion([])
                    return
                }
                
                // 2. matchId로 실제 Match 데이터 가져오기
                self.fetchMatchesByIds(matchIds: matchIds, completion: completion)
            }
    }
    
    /// matchId 목록으로 Match 데이터 가져오기
    /// - Parameters:
    ///   - matchIds: matchId 배열
    ///   - completion: Match 배열을 반환하는 클로저
    private func fetchMatchesByIds(matchIds: [String], completion: @escaping ([Match]) -> Void) {
        // Firestore의 'in' 쿼리는 최대 10개까지만 지원
        // 10개씩 나눠서 요청
        let batchSize = 10
        var allMatches: [Match] = []
        let group = DispatchGroup()
        
        for i in stride(from: 0, to: matchIds.count, by: batchSize) {
            let batch = Array(matchIds[i..<min(i + batchSize, matchIds.count)])
            
            group.enter()
            
            db.collection("matches")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments { snapshot, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("❌ Matches 불러오기 실패: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        return
                    }
                    
                    let matches = documents.compactMap { doc -> Match? in
                        let decoder = Firestore.Decoder()
                        decoder.userInfo[Match.documentIdKey] = doc.documentID
                        
                        do {
                            return try doc.data(as: Match.self, decoder: decoder)
                        } catch {
                            print("❌ Match 디코딩 실패: \(error)")
                            return nil
                        }
                    }
                    
                    allMatches.append(contentsOf: matches)
                }
        }
        
        group.notify(queue: .main) {
            print("✅ 스크랩한 매치 \(allMatches.count)개 불러오기 완료")
            completion(allMatches)
        }
    }
}
