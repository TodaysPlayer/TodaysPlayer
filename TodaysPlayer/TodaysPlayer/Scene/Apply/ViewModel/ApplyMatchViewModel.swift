//
//  ApplyMatchViewModel.swift
//  TodaysPlayer
//
//  매칭 신청 화면의 비즈니스 로직을 담당하는 ViewModel
//

import Foundation
import Combine
//import AlanAI

/// 매칭 신청 화면의 상태 관리 및 비즈니스 로직
@MainActor
class ApplyMatchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 자기소개 메시지
    @Published var message: String = ""
    
    /// 선택한 포지션
    @Published var position: String = ""
    
    /// 참가 인원
    @Published var participantCount: Int = 1
    
    /// AI 생성 중 로딩 상태
    @Published var isGeneratingAI: Bool = false
    
    /// 신청 제출 중 로딩 상태
    @Published var isSubmitting: Bool = false
    
    /// 성공 알림 표시 여부
    @Published var showSuccessAlert: Bool = false
    
    /// 에러 알림 표시 여부
    @Published var showErrorAlert: Bool = false
    
    /// 에러 메시지
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    
    //private let aiService: AIIntroductionService
    private let aiStreamService: AIIntroductionStreamService
    private var currentGenerationTask: Task<Void, Never>?
    private let match: Match
    
    // MARK: - Computed Properties
    
    /// 신청하기 버튼 활성화 조건
    var isFormValid: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Initialization
    
    init(match: Match, aiClientID: String) {
        self.match = match
        //self.aiService = AIIntroductionService(clientID: aiClientID)
        self.aiStreamService = AIIntroductionStreamService(clientID: aiClientID)

    }
    
    // MARK: - Public Methods
    
    /// AI로 자기소개 생성 (SSE 스트리밍 방식)
    func generateAIIntroduction() {
        cancelGeneration()
        
        isGeneratingAI = true
        errorMessage = ""
        message = ""
        
        currentGenerationTask = Task {
            do {
                try Task.checkCancellation()
                
                // 1. 현재 사용자 정보 가져오기
                let userId = AuthHelper.currentUserId
                let user = try await FirestoreManager.shared.getDocument(
                    collection: "users",
                    documentId: userId,
                    as: User.self
                )
                
                guard let user = user else {
                    throw AIIntroductionError.invalidRequest
                }
                
                try Task.checkCancellation()
                
                // 2. 포지션 우선순위: View 선택 → User 프로필 → nil
                let selectedPosition = position.isEmpty ? user.position : position
                
                // 3. 🆕 SSE 스트리밍으로 AI 호출
                try await aiStreamService.generateIntroductionStream(
                    position: selectedPosition,
                    skillLevel: user.skillLevel
                ) { [weak self] accumulatedText in
                    // 실시간으로 메시지 업데이트
                    Task { @MainActor in
                        guard !Task.isCancelled else { return }
                        self?.message = accumulatedText
                    }
                }
                
                print("AI 자기소개 스트리밍 완료")
                
            } catch is CancellationError {
                print("AI 생성이 취소되었습니다")
                
            } catch let error as AIIntroductionError {
                // 커스텀 에러 처리
                errorMessage = error.localizedDescription
                showErrorAlert = true
                print("AI 생성 에러: \(error)")
                
            } catch {
                // 기타 에러
                errorMessage = "예상치 못한 오류가 발생했습니다."
                showErrorAlert = true
                print("알 수 없는 에러: \(error)")
            }
            
            isGeneratingAI = false
            currentGenerationTask = nil
        }
    }
    
    func cancelGeneration() {
        currentGenerationTask?.cancel()
        aiStreamService.cancel()
        currentGenerationTask = nil
        isGeneratingAI = false
    }
    
    /// 매칭 신청 제출
    func submitApplication() {
        guard !isSubmitting else {
            print("이미 신청 처리 중입니다")
            return
        }
        
        isSubmitting = true
        
        Task {
            do {
                let userId = AuthHelper.currentUserId
                
                // User 정보 가져오기 (닉네임, 실력 등)
                let user = try await FirestoreManager.shared.getDocument(
                    collection: "users",
                    documentId: userId,
                    as: User.self
                )
                
                guard let user = user else {
                    throw NSError(domain: "ApplyMatchViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."])
                }
                
                // Apply 객체 생성
                let apply = Apply(
                    id: UUID().uuidString,
                    matchId: match.id,
                    userId: userId,
                    userNickname: user.displayName,
                    userSkillLevel: user.skillLevel,
                    position: position.isEmpty ? nil : position,
                    participantCount: participantCount,
                    message: message,
                    status: "pending",
                    rejectionReason: nil,
                    appliedAt: Date(),
                    processedAt: nil,
                    userRate: user.userRate
                )
                
                // Firebase에 저장
                _ = try await FirestoreManager.shared.createDocument(
                    collection: "apply",
                    data: apply
                )
                
                // Match 문서의 participants 업데이트
                try await FirestoreManager.shared.updateDocument(
                    collection: "matches",
                    documentId: match.id,
                    data: [
                        "participants.\(userId)": "pending"
                    ]
                )
                
                print("매칭 신청 완료: \(apply.id)")
                
                showSuccessAlert = true
                
            } catch {
                print("매칭 신청 실패: \(error)")
                errorMessage = "신청 중 오류가 발생했습니다.\n다시 시도해주세요."
                showErrorAlert = true
                isSubmitting = false
            }
        }
    }
    
    deinit {
       currentGenerationTask?.cancel()
       aiStreamService.cancel()
   }
}
