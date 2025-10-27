//
//  NextMatchCard.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct NextMatchCard: View {
    @Environment(TabSelection.self) var tabSelection
    @State private var showNavigationAlert = false
    @State private var matchToNavigate: Match?
    
    let user: User?
    let nextMatch: Match?
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text(user?.displayName ?? "골린이")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            
                            Text("님")
                                .font(.system(size: 16))
                        }
                        
                        Text("최근 경기 정보를 알려드릴게요~!")
                            .font(.subheadline)
                            .font(.system(size: 16))
                            .padding(.top, 1)
                    }
                    
                    Spacer()
                    
                    Text(calculateDaysUntilMatch())
                        .font(.system(size: 12))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(calculateDaysUntilMatch() == "경기없음" ? .gray : .red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.vertical, 16)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                        .font(.system(size: 16))
                    
                    Text("다음 경기")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    
                    Spacer()
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 16)
            
            // 다음 경기 카드
            if let match = nextMatch {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14))
                                
                                Text(match.dateTime.formatForDisplay())
                                    .font(.subheadline)
                                    .foregroundStyle(.black)
                            }
                            
                            HStack(alignment: .center) {
                                Image(systemName: "location")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(match.location.name)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.black)
                                    
                                    Text(match.location.address)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        
                        Button(action: {
                            // 길찾기 기능 - 얼럿 표시 후 이동
                            matchToNavigate = nextMatch
                            showNavigationAlert = true
                        }) {
                            HStack {
                                Image(systemName: "point.topright.arrow.triangle.backward.to.point.bottomleft.filled.scurvepath")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14))
                                
                                Text("길찾기")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                // 다음 경기가 없는 경우
                Button {
                    tabSelection.selectedTab = 1
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray)
                        
                        Text("다음 경기가 없습니다")
                            .font(.headline)
                            .foregroundStyle(.gray)
                        
                        Text("새로운 매치에 참여해보세요!")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .alert("지도 앱으로 이동", isPresented: $showNavigationAlert) {
            Button("취소", role: .cancel) {
                matchToNavigate = nil
            }
            Button("이동") {
                openAppleMap(to: matchToNavigate)
                matchToNavigate = nil
            }
        } message: {
            Text("Apple 지도 앱으로 이동하여 길찾기를 시작하시겠습니까?")
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateDaysUntilMatch() -> String {
        guard let match = nextMatch else {
            return "경기없음"
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘과 경기일의 날짜만 비교 (시간 제외)
        let todayStart = calendar.startOfDay(for: today)
        let matchStart = calendar.startOfDay(for: match.dateTime)
        
        let days = calendar.dateComponents([.day], from: todayStart, to: matchStart).day ?? 0
        
        if days == 0 {
            return "D-Day"
        } else if days == 1 {
            return "D-1"
        } else {
            return "D-\(days)"
        }
    }
    
    private func openAppleMap(to match: Match?) {
        if let match {
            // 좌표 생성
            let latitude = match.location.coordinates.latitude
            let longitude = match.location.coordinates.longitude
            let name = match.location.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            // Apple Maps URL
            let urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d&q=\(name)"
            
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    NextMatchCard(user: nil, nextMatch: nil)
}
