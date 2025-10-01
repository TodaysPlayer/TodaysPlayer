//
//  FilterBottomSheet.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/28/25.
//

import SwiftUI

struct FilterBottomSheet: View {
    // 부모 뷰에서 받아올 데이터
    @Binding var currentFilter: GameFilter
    @Binding var isPresented: Bool
    @State private var tempFilter: GameFilter
    
    // 필터 선택 여부를 확인하는 computed property
    private var hasActiveFilters: Bool {
        tempFilter.matchType != nil ||
        !tempFilter.skillLevels.isEmpty ||
        tempFilter.gender != nil ||
        tempFilter.feeType != nil
    }
    
    // 생성자에서 tempFilter 초기화
    init(currentFilter: Binding<GameFilter>, isPresented: Binding<Bool>) {
        self._currentFilter = currentFilter
        self._isPresented = isPresented
        self._tempFilter = State(initialValue: currentFilter.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text("필터")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 8)
            
            // 필터 옵션들
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 경기 종류 섹션 - MatchType 사용
                    filterSection(title: "경기 종류") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(MatchType.allCases, id: \.self) { matchType in
                                filterToggleButton(
                                    title: matchType.rawValue,
                                    isSelected: tempFilter.matchType == matchType,
                                    color: matchType.backgroundColor
                                ) {
                                    tempFilter.matchType = (tempFilter.matchType == matchType) ? nil : matchType
                                }
                            }
                        }
                    }
                    
                    // 실력 레벨 섹션 - SkillLevel enum 사용
                    filterSection(title: "실력") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(SkillLevel.allCases, id: \.self) { skillLevel in
                                filterToggleButton(
                                    title: skillLevel.rawValue,
                                    isSelected: tempFilter.skillLevels.contains(skillLevel)
                                ) {
                                    if tempFilter.skillLevels.contains(skillLevel) {
                                        tempFilter.skillLevels.remove(skillLevel)
                                    } else {
                                        tempFilter.skillLevels.insert(skillLevel)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 성별 섹션 - Gender enum 사용
                    filterSection(title: "성별") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                filterToggleButton(
                                    title: gender.rawValue,
                                    isSelected: tempFilter.gender == gender
                                ) {
                                    tempFilter.gender = (tempFilter.gender == gender) ? nil : gender
                                }
                            }
                        }
                    }
                    
                    // 참가비 섹션 - FeeType enum 사용
                    filterSection(title: "참가비") {
                        LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
                            ForEach(FeeType.allCases, id: \.self) { feeType in
                                filterToggleButton(
                                    title: feeType.rawValue,
                                    isSelected: tempFilter.feeType == feeType
                                ) {
                                    tempFilter.feeType = (tempFilter.feeType == feeType) ? nil : feeType
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100) // 하단 버튼 공간 확보
            }
            
            // 하단 버튼들
            VStack(spacing: 12) {
                Divider()
                
                HStack(spacing: 12) {
                    // 조건 초기화 버튼
                    Button(action: {
                        tempFilter = GameFilter()
                    }) {
                        Text("조건 초기화")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(hasActiveFilters ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(hasActiveFilters ? Color.green : Color(.systemGray5))
                        .cornerRadius(12)
                    }
                    
                    // 적용하기 버튼
                    Button(action: {
                        currentFilter = tempFilter  // 부모의 currentFilter에 적용
                        isPresented = false
                        
                        // 필터 적용 로직 (나중에 ViewModel로 이동 예정)
                        let filterDict = currentFilter.toDictionary()
                        print("적용된 필터:", filterDict)
                        
                        // 여기서 서버에 필터 조건을 보내고 결과를 받아올 수 있습니다
                    }) {
                        Text("적용하기")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemBackground))
        .presentationDetents([.height(500)])
        .presentationDragIndicator(.hidden)
        .onAppear {
            // 시트가 나타날 때마다 현재 필터를 tempFilter에 복사
            tempFilter = currentFilter
        }
    }
    
    // 필터 섹션 헬퍼 함수
    private func filterSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            content()
        }
    }
    
    // 필터 토글 버튼 헬퍼 함수 - color 파라미터 추가
    private func filterToggleButton(
        title: String,
        isSelected: Bool,
        color: Color = .blue,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? color : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

#Preview {
    @Previewable @State var currentFilter = GameFilter()
    @Previewable @State var isPresented = true
    
    return FilterBottomSheet(
        currentFilter: $currentFilter,
        isPresented: $isPresented
    )
}
