//
//  TestView.swift
//  TodaysPlayer
//
//  Created by AI on 10/1/25.
//

import SwiftUI

struct TestView: View {
    // 장소 검색 관련
    @State private var showLocationSearch = false
    @State private var selectedLocation: MatchLocation?
    
    var body: some View {
        searchTestButton
            .sheet(isPresented: $showLocationSearch) {
                LocationSearchBottomSheet(
                    isPresented: $showLocationSearch,
                    selectedMatchLocation: $selectedLocation
                )
            }
            .onChange(of: selectedLocation) { _, newValue in
                if let location = newValue {
                    print("✅ 선택된 장소: \(location.name)")
                    print("   주소: \(location.address)")
                    print("   좌표: \(location.coordinates.latitude), \(location.coordinates.longitude)")
                }
            }
    }
    
    // MARK: - 장소 검색 테스트 버튼
    
    private var searchTestButton: some View {
        Button(action: {
            showLocationSearch = true
        }) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    
                    Text("🔍 장소 검색 테스트")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green)
                .clipShape(Capsule())
                
                Text("개발용: 장소 검색 기능을 테스트합니다")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if let location = selectedLocation {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("선택된 장소: \(location.name)")
                            .font(.caption2)
                            .fontWeight(.bold)
                        Text("주소: \(location.address)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    TestView()
}
