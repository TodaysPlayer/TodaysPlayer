//
//  RegionBottomSheet.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/28/25.
//

import SwiftUI

struct RegionBottomSheet: View {
    // 부모 뷰에서 받아올 데이터
    @ObservedObject var filterViewModel: FilterViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // 바텀시트 헤더
                HStack {
                    Text("지역")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("완료") {
                        isPresented = false
                    }
                    .foregroundColor(.primaryBaseGreen)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // 지역 목록
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Region.allCases, id: \.self) { region in
                            VStack(spacing: 0) {
                                regionRow(region)
                                
                                // Divider 추가
                                if region != Region.allCases.last {
                                    Divider()
                                        .padding(.leading, 20)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // 지역 선택 행
    private func regionRow(_ region: Region) -> some View {
        Button(action: {
            filterViewModel.updateRegion(region)
            isPresented = false
        
            print("선택된 지역: \(region.rawValue)")
        }) {
            HStack {
                Text(region.rawValue)
                    .foregroundColor(.primary)
                    .font(.body)
                
                Spacer()
                
                if filterViewModel.currentFilter.region == region {
                    Image(systemName: "checkmark")
                        .foregroundColor(.primaryBaseGreen)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)  // 전체 너비
            .contentShape(Rectangle())  // 전체 영역 터치 가능하도록 변경
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
