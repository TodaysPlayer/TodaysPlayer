//
//  FilterBottomSheet.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/28/25.
//

import SwiftUI

struct FilterBottomSheet: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var filterViewModel: FilterViewModel
    
    @State private var tempFilter: GameFilter
    
    private var hasActiveFilters: Bool {
        tempFilter.matchType != nil ||
        !tempFilter.skillLevels.isEmpty ||
        tempFilter.gender != nil ||
        tempFilter.feeType != nil
    }
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._tempFilter = State(initialValue: GameFilter())
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
                    // 경기 종류 섹션
                    filterSection(title: "경기 종류") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(MatchType.allCases, id: \.self) { matchType in
                                filterToggleButton(
                                    title: matchType.rawValue,
                                    isSelected: tempFilter.matchType == matchType,
                                    color: .primaryBaseGreen
                                ) {
                                    tempFilter.matchType = (tempFilter.matchType == matchType) ? nil : matchType
                                }
                            }
                        }
                    }
                    
                    // 실력 레벨 섹션
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
                                    isSelected: tempFilter.skillLevels.contains(skillLevel),
                                    color: .primaryBaseGreen
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
                    
                    // 성별 섹션
                    filterSection(title: "성별") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                filterToggleButton(
                                    title: gender.rawValue,
                                    isSelected: tempFilter.gender == gender,
                                    color: .primaryBaseGreen
                                ) {
                                    tempFilter.gender = (tempFilter.gender == gender) ? nil : gender
                                }
                            }
                        }
                    }
                    
                    // 참가비 섹션
                    filterSection(title: "참가비") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(FeeType.allCases, id: \.self) { feeType in
                                filterToggleButton(
                                    title: feeType.rawValue,
                                    isSelected: tempFilter.feeType == feeType,
                                    color: .primaryBaseGreen
                                ) {
                                    tempFilter.feeType = (tempFilter.feeType == feeType) ? nil : feeType
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            // 하단 버튼들
            VStack(spacing: 12) {
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: {
                        tempFilter = GameFilter()
                    }) {
                        Text("조건 초기화")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(hasActiveFilters ? Color.secondaryDeepGray.opacity(0.5): Color.secondaryCoolGray)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // ViewModel에 필터 적용
                        filterViewModel.currentFilter = tempFilter
                        filterViewModel.applyFilter()
                        
                        // 시트 닫기
                        isPresented = false
                    }) {
                        Text("적용하기")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primaryBaseGreen)
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
            tempFilter = filterViewModel.currentFilter
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
    
    // 필터 토글 버튼 헬퍼 함수
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
