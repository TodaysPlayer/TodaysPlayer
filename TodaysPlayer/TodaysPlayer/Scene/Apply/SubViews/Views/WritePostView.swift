//  WritePostView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/28/25.
//

import SwiftUI

struct WritePostView: View {
    @State private var viewModel = WritePostViewModel()
    @State private var showCalendar = false
    @State private var toastManager = ToastMessageManager()
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var filterViewModel: FilterViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                ZStack(alignment: .bottom) {
                    Color.gray.opacity(0.1)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // 제목 입력
                            FormSection(title: "제목") {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    TextField("경기 제목을 입력하세요", text: $viewModel.title)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
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
                            FormSection(title: "경기 날짜") {
                                Button(action: { showCalendar = true }) {
                                    HStack {
                                        Text(dateFormatter.string(from: viewModel.selectedDate))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "calendar")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            // 시간 입력
                            FormSection(title: "경기 시간") {
                                HStack(spacing: 12) {
                                    // 시작 시간
                                    Button {
                                        viewModel.showStartTimePicker = true
                                    } label: {
                                        Text(timeFormatter.string(from: viewModel.startTime))
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                    
                                    Text("~")
                                        .foregroundColor(.gray)
                                    
                                    // 종료 시간
                                    Button {
                                        viewModel.showEndTimePicker = true
                                    } label: {
                                        Text(timeFormatter.string(from: viewModel.endTime))
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            
                            // 구장 선택
                            FormSection(title: "구장명") {
                                Button {
                                    viewModel.showLocationSearch = true
                                } label: {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                        Text(viewModel.selectedLocation?.name ?? "구장을 검색하세요")
                                            .foregroundColor(viewModel.selectedLocation == nil ? Color.secondaryDeepGray : Color.primaryBaseGreen)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
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
                            
                            // 모집 상세
                            FormSection(title: "모집 상세") {
                                TextEditor(text: $viewModel.description)
                                    .frame(minHeight: 150)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        Group {
                                            if viewModel.description.isEmpty {
                                                Text("매칭에 대해 알려주세요\n(팀이름/연령대/소개 등)")
                                                    .foregroundColor(.gray)
                                                    .padding(.top, 16)
                                                    .padding(.leading, 12)
                                                    .allowsHitTesting(false)
                                            }
                                        },
                                        alignment: .topLeading
                                    )
                            }
                            
                            // 모집 인원
                            FormSection(title: "모집할 인원") {
                                HStack(spacing: 12) {
                                    // 마이너스 버튼
                                    Button {
                                        if viewModel.maxParticipants > 1 {
                                            viewModel.maxParticipants -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(viewModel.maxParticipants > 1 ? .primary : .gray)
                                            .frame(width: 44, height: 44)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                    .disabled(viewModel.maxParticipants <= 1)
                                    
                                    // 입력 필드
                                    HStack {
                                        TextField("최대 30명까지 모집 가능", text: Binding(
                                            get: {
                                                viewModel.maxParticipants == 0 ? "" : "\(viewModel.maxParticipants)"
                                            },
                                            set: { newValue in
                                                if newValue.isEmpty {
                                                    viewModel.maxParticipants = 0
                                                } else {
                                                    let value = Int(newValue) ?? 0
                                                    viewModel.maxParticipants = min(value, 30)
                                                }
                                            }
                                        ))
                                        
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.center)
                                        
                                        if viewModel.maxParticipants > 0 {
                                            Text("명")
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    
                                    // 플러스 버튼
                                    Button {
                                        if viewModel.maxParticipants == 0 {
                                            viewModel.maxParticipants = 1
                                        } else if viewModel.maxParticipants < 30 {
                                            viewModel.maxParticipants += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(viewModel.maxParticipants < 30 ? .primary : .gray)
                                            .frame(width: 44, height: 44)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                    .disabled(viewModel.maxParticipants >= 30)
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
                                    HStack(spacing: 12) {
                                        Button {
                                            viewModel.hasFee = false
                                            viewModel.price = 0
                                        } label: {
                                            HStack {
                                                Image(systemName: viewModel.hasFee ? "circle" : "checkmark.circle.fill")
                                                    .foregroundColor(viewModel.hasFee ? .secondaryDeepGray : .primaryBaseGreen)
                                                Text("없어요")
                                                    .foregroundColor(.primary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
                                        }
                                        
                                        Button {
                                            viewModel.hasFee = true
                                        } label: {
                                            HStack {
                                                Image(systemName: viewModel.hasFee ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(viewModel.hasFee ? .primaryBaseGreen : .secondaryDeepGray)
                                                Text("있어요")
                                                    .foregroundColor(.primary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
                                        }
                                    }
                                    
                                    if viewModel.hasFee {
                                        HStack {
                                            TextField("최대 20,000원까지 입력", text: Binding(
                                                get: {
                                                    if viewModel.price == 0 {
                                                        return ""
                                                    } else {
                                                        let formatter = NumberFormatter()
                                                        formatter.numberStyle = .decimal
                                                        formatter.groupingSeparator = ","
                                                        return formatter.string(from: NSNumber(value: viewModel.price)) ?? "\(viewModel.price)"
                                                    }
                                                },
                                                set: { newValue in
                                                    let filtered = newValue.filter { $0.isNumber }
                                                    viewModel.price = Int(filtered) ?? 0
                                                }
                                            ))
                                            .keyboardType(.numberPad)
                                            
                                            if viewModel.price > 0 {
                                                Text("원")
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 80)
                    }
                    
                    // 하단 고정 등록 버튼
                    VStack(spacing: 0) {
                        Divider()
                        
                        Button {
                            Task {
                                do {
                                    guard AuthHelper.isLoggedIn else {
                                        viewModel.errorMessage = "로그인이 필요합니다."
                                        return
                                    }
                                    
                                    let userId = AuthHelper.currentUserId
                                    let newMatch = try await viewModel.createMatch(organizerId: userId)
                                    
                                    filterViewModel.addNewMatch(newMatch)
                                    filterViewModel.selectedDate = newMatch.dateTime
                                    filterViewModel.applyFilter()
                                    
                                    toastManager.show(.postCreated, duration: 2.0)
                                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                                    
                                    dismiss()
                                    
                                } catch {
                                    viewModel.isSubmitting = false
                                    viewModel.isLoading = false
                                    viewModel.errorMessage = error.localizedDescription
                                }
                            }
                        } label: {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("등록하기")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(
                        (viewModel.isFormValid && !viewModel.isSubmitting) ? Color.primaryBaseGreen : Color.secondaryDeepGray)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                        .padding(.vertical, 12)
                    }
                    .background(Color.gray.opacity(0.1))
                }
                .navigationTitle("용병 모집하기")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .tabBar)
                .sheet(isPresented: $showCalendar) {
                    MonthCalendarSheet(selectedDate: $viewModel.selectedDate, showCalendar: $showCalendar)
                        .presentationDetents([.height(600)])
                }
                .sheet(isPresented: $viewModel.showLocationSearch) {
                    LocationSearchBottomSheet(
                        isPresented: $viewModel.showLocationSearch,
                        selectedMatchLocation: $viewModel.selectedLocation
                    )
                }
                .sheet(isPresented: $viewModel.showStartTimePicker) {
                    TimePickerSheet(
                        selectedTime: $viewModel.startTime,
                        showPicker: $viewModel.showStartTimePicker,
                        title: "시작 시간"
                    )
                    .presentationDetents([.height(310)])
                    .presentationDragIndicator(.hidden)
                }
                .sheet(isPresented: $viewModel.showEndTimePicker) {
                    TimePickerSheet(
                        selectedTime: $viewModel.endTime,
                        showPicker: $viewModel.showEndTimePicker,
                        title: "종료 시간"
                    )
                    .presentationDetents([.height(310)])
                    .presentationDragIndicator(.hidden)
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
                ToastMessageView(manager: toastManager)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    @Binding var showPicker: Bool
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button("완료") {
                    showPicker = false
                }
                .foregroundColor(.primaryBaseGreen)
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            // 피커
            DatePicker(
                "",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .padding()
            .background(Color.white)
        }
        .background(Color.white)
        .presentationBackground(Color.white)
    }
}

// MARK: - 월간 캘린더 시트
struct MonthCalendarSheet: View {
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                MonthCalendarView(selectedDate: $selectedDate)
                    .frame(height: 400)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    showCalendar = false
                }) {
                    Text("완료")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryBaseGreen)
                        .cornerRadius(12)
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("날짜 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCalendar = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primaryBaseGreen)
                            .font(.system(size: 16, weight: .semibold))
                    }
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
                .font(.system(size: 16, weight: .semibold))
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
                .background(isSelected ? Color.primaryBaseGreen : Color.white)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
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
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedLevel == level.0 ? Color.primaryBaseGreen : Color.white)
                        .foregroundColor(selectedLevel == level.0 ? .white : .primary)
                        .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Gender Picker
struct GenderPicker: View {
    @Binding var selectedGender: String
    
    let genders = [
        ("mixed", "혼성"),
        ("male", "남성"),
        ("female", "여성")
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(genders, id: \.0) { gender in
                Button {
                    selectedGender = gender.0
                } label: {
                    Text(gender.1)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedGender == gender.0 ? Color.primaryBaseGreen : Color.white)
                        .foregroundColor(selectedGender == gender.0 ? .white : .primary)
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    WritePostView()
}
