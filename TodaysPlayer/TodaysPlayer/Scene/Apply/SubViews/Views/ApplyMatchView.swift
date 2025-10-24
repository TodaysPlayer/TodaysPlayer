//
//  ApplyMatchView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/30/25.
//

import SwiftUI

struct ApplyMatchView: View {
    let match: Match
    
    // ViewModel 연결
    @StateObject private var viewModel: ApplyMatchViewModel
    
    @State private var toastManager = ToastMessageManager()
    
    @Environment(\.dismiss) private var dismiss
    
    // init에서 ViewModel 초기화
    init(match: Match, aiClientID: String = "c81645d9-ead6-4a91-9e47-f81311287298") {
        self.match = match
        _viewModel = StateObject(wrappedValue: ApplyMatchViewModel(match: match, aiClientID: aiClientID))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 상단 타이틀
                    VStack(alignment: .leading, spacing: 8) {
                        Text("용병 신청")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("매칭 참여를 위해 본인을 간단히 소개해주세요.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // 신청하는 매치 정보 카드
                    ApplyMatchInfoCard(match: match)
                        .padding(.horizontal, 20)
                    
                    // 포지션 선택 (선택사항)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("선호 포지션 (선택)")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            positionButton("공격수", isSelected: viewModel.position == "공격수")
                            positionButton("미드필더", isSelected: viewModel.position == "미드필더")
                            positionButton("수비수", isSelected: viewModel.position == "수비수")
                            positionButton("골키퍼", isSelected: viewModel.position == "골키퍼")
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 자기소개 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("자기소개 및 각오")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // 텍스트 에디터
                            ZStack(alignment: .topLeading) {
                                if viewModel.message.isEmpty {
                                    Text("본인의 플레이 스타일, 축구 경력, 각오 등을 간단히 소개해주세요.\n\n예) 안녕하세요! 축구 경력 3년차로 수비를 담당하고 있습니다. 패스워크를 중시하며 팀워크를 중요하게 생각합니다. 좋은 경기 만들어가요!")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                                
                                TextEditor(text: $viewModel.message)
                                    .font(.body)
                                    .frame(minHeight: 200)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .scrollContentBackground(.hidden)
                                    .disabled(viewModel.isGeneratingAI) // AI 생성 중엔 비활성화
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            
                            // AI 작성 버튼 (ViewModel 연결)
                            Button(action: {
                                viewModel.generateAIIntroduction()
                            }) {
                                HStack {
                                    if viewModel.isGeneratingAI {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 16))
                                    }
                                    
                                    Text(viewModel.isGeneratingAI ? "AI 작성 중..." : "AI로 자기소개 완성하기")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    viewModel.isGeneratingAI ?
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isGeneratingAI)
                            .padding(.horizontal, 20)
                            
                            // 안내 문구
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                
                                Text("신청 전 확인해주세요")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                bulletPoint("허위 정보 작성 시 매칭이 불가능할 수 있습니다")
                                bulletPoint("매칭 신청 후 주최자의 승인을 기다려주세요")
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("매칭 신청")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                viewModel.cancelGeneration()
            }
            .safeAreaInset(edge: .bottom) {
                // 하단 신청 버튼
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        viewModel.submitApplication()
                    }) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text("신청하기")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .background(viewModel.isFormValid ? Color.green : Color.gray)
                    .cornerRadius(12)
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemBackground))
            }
            .onChange(of: viewModel.showSuccessAlert) { oldValue, newValue in
                if newValue {
                    // Toast 표시
                    toastManager.show(.applyCompleted, duration: 2.0)
                    
                    // 2초 후 화면 닫기
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        dismiss()
                    }
                    
                    // 플래그 리셋
                    viewModel.showSuccessAlert = false
                }
            }
            .alert("오류", isPresented: $viewModel.showErrorAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            ToastMessageView(manager: toastManager)
        }
    }
    
    // 포지션 버튼
    private func positionButton(_ title: String, isSelected: Bool) -> some View {
        Button(action: {
            if viewModel.position == title {
                viewModel.position = "" // 선택 해제
            } else {
                viewModel.position = title
            }
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(16)
        }
    }
    
    // 불릿 포인트 헬퍼
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 신청하는 매치 정보 카드
struct ApplyMatchInfoCard: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 제목
            HStack {
                Text(match.matchType == "futsal" ? "풋살" : "축구")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(match.matchType == "futsal" ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Spacer()
            }
            
            Text(match.title)
                .font(.headline)
            
            Divider()
            
            // 경기 정보
            VStack(spacing: 12) {
                infoRow(icon: "calendar", title: "날짜", value: formatDate(match.dateTime))
                infoRow(icon: "clock", title: "시간", value: formatTime(match.dateTime, duration: match.duration))
                infoRow(icon: "mappin.circle", title: "장소", value: match.location.name)
                infoRow(icon: "wonsign.circle", title: "참가비", value: "\(match.price.formatted())원")
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date, duration: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let startTime = formatter.string(from: date)
        let endDate = date.addingTimeInterval(TimeInterval(duration * 60))
        let endTime = formatter.string(from: endDate)
        return "\(startTime)~\(endTime)"
    }
}

#Preview {
    NavigationStack {
        ApplyMatchView(
            match: Match(
                id: "preview",
                title: "주말 풋살 매치",
                description: "함께 즐거운 경기 해요!",
                organizerId: "user123",
                organizerName: "미드필더박영희",
                organizerProfileURL: "",
                teamId: nil,
                matchType: "futsal",
                gender: "mixed",
                location: MatchLocation(
                    name: "성북 풋살파크",
                    address: "서울특별시 성북구",
                    coordinates: Coordinates(latitude: 37.5, longitude: 127.0)
                ),
                dateTime: Date(),
                duration: 120,
                maxParticipants: 12,
                skillLevel: "beginner",
                position: nil,
                price: 5000,
                rating: nil,
                status: "recruiting",
                tags: [],
                requirements: nil,
                participants: [:],
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    }
}
