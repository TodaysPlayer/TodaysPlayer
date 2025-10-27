//
//  SortControlView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/24/25.
//

import SwiftUI


/// 경기 정렬 옵션
enum MatchSortOption: String, CaseIterable {
    case matchDateAsc = "경기 날짜 오름차순"
    case matchDateDesc = "경기 날짜 내림차순"
    case createdAtAsc = "등록일 오름차순"
    case createdAtDesc = "등록일 내림차순"

    var title: String { rawValue }
}


/// 경기 정렬 버튼
struct SortSheetButtonView: View {
    @State private var showSortSheet = false
    @Binding var selectedOption: MatchSortOption
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                showSortSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.title3)
                    Text("정렬")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(.secondaryDeepGray)
            }
            .sheet(isPresented: $showSortSheet) {
                SortBottomSheet(selectedOption: $selectedOption)
                    .presentationDetents([.fraction(0.3)])
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
}


/// 경기정렬 바텀시트
struct SortBottomSheet: View {
    @Binding var selectedOption: MatchSortOption
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.vertical, 8)
            
            Text("정렬 기준 선택")
                .font(.headline)
                .padding(.bottom, 12)
            
            ForEach(MatchSortOption.allCases, id: \.self) { option in
                Button {
                    selectedOption = option
                    dismiss()
                } label: {
                    HStack {
                        Text(option.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedOption == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 10)
    }
}
