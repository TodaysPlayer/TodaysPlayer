//
//  WritePostView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/28/25.
//

import SwiftUI

struct WritePostView: View {
    @State private var viewModel = WritePostViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 제목 입력
                    FormSection(title: "제목") {
                        TextField("경기 제목을 입력하세요", text: $viewModel.title)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // 경기 종류
                    FormSection(title: "경기 종류") {
                        HStack(spacing: 12) {
                            MatchTypeButton(
                                type: "futsal",
                                title: "풋살",
                                isSelected: viewModel.matchType == "futsal"
                            ) {
                                viewModel.matchType = "futsal"
                            }
                            
                            MatchTypeButton(
                                type: "soccer",
                                title: "축구",
                                isSelected: viewModel.matchType == "soccer"
                            ) {
                                viewModel.matchType = "soccer"
                            }
                        }
                    }
                    
                    // 날짜 선택
                    FormSection(title: "날짜") {
                        DatePicker(
                            "경기 날짜",
                            selection: $viewModel.selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                    }
                    
                    // 시간 입력
                    FormSection(title: "시간") {
                        HStack(spacing: 12) {
                            TextField("시작 시간 (예: 18:00)", text: $viewModel.startTime)
                                .textFieldStyle(.roundedBorder)
                            
                            Text("~")
                            
                            TextField("종료 시간 (예: 20:00)", text: $viewModel.endTime)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    // 구장 선택
                    FormSection(title: "구장명") {
                        Button {
                            viewModel.showLocationSearch = true
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text(viewModel.selectedLocation?.name ?? "구장을 검색하세요")
                                    .foregroundColor(viewModel.selectedLocation == nil ? .gray : .primary)
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        if let location = viewModel.selectedLocation {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.address)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    // 모집 인원
                    FormSection(title: "모집 인원") {
                        Stepper(
                            value: $viewModel.maxParticipants,
                            in: 1...22
                        ) {
                            Text("\(viewModel.maxParticipants)명")
                        }
                    }
                    
                    // 실력
                    FormSection(title: "실력") {
                        SkillLevelPicker(selectedLevel: $viewModel.skillLevel)
                    }
                    
                    // 성별
                    FormSection(title: "성별") {
                        GenderPicker(selectedGender: $viewModel.gender)
                    }
                    
                    // 참가비
                    FormSection(title: "참가비") {
                        VStack(spacing: 12) {
                            Toggle("참가비 있음", isOn: $viewModel.hasFee)
                            
                            if viewModel.hasFee {
                                TextField("참가비 (원)", value: $viewModel.price, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    
                    // 경기 상세 설명
                    FormSection(title: "모집 상세") {
                        TextEditor(text: $viewModel.description)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("용병 모집하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("등록") {
                        Task {
                            do {
                                // TODO: 현재 사용자 ID 가져오기
                                let userId = "currentUserId"
                                _ = try await viewModel.createMatch(organizerId: userId)
                                dismiss()
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .sheet(isPresented: $viewModel.showLocationSearch) {
                LocationSearchBottomSheet(
                    isPresented: $viewModel.showLocationSearch,
                    selectedMatchLocation: $viewModel.selectedLocation
                )
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Form Section Component
struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content
        }
    }
}

// MARK: - Match Type Button
struct MatchTypeButton: View {
    let type: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? (type == "futsal" ? Color.green : Color.blue) : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

// MARK: - Skill Level Picker
struct SkillLevelPicker: View {
    @Binding var selectedLevel: String
    
    let levels = [
        ("beginner", "입문자"),
        ("intermediate", "초급"),
        ("advanced", "중급"),
        ("expert", "상급")
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(levels, id: \.0) { level in
                Button {
                    selectedLevel = level.0
                } label: {
                    Text(level.1)
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(selectedLevel == level.0 ? Color.blue : Color(.systemGray5))
                        .foregroundColor(selectedLevel == level.0 ? .white : .primary)
                        .cornerRadius(6)
                }
            }
        }
    }
}

// MARK: - Gender Picker
struct GenderPicker: View {
    @Binding var selectedGender: String
    
    let genders = [
        ("mixed", "무관"),
        ("male", "남성"),
        ("female", "여성")
    ]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(genders, id: \.0) { gender in
                Button {
                    selectedGender = gender.0
                } label: {
                    Text(gender.1)
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(selectedGender == gender.0 ? Color.blue : Color(.systemGray5))
                        .foregroundColor(selectedGender == gender.0 ? .white : .primary)
                        .cornerRadius(6)
                }
            }
        }
    }
}

#Preview {
    WritePostView()
}
