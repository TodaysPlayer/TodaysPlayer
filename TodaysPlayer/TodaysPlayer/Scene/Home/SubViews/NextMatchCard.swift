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
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(calculateDaysUntilMatch() == "경기없음" ? .gray : .red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.vertical, 16)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    
                    Text("다음 경기")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
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
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                
                                Text(match.dateTime.formatForDisplay())
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            
                            HStack(alignment: .center) {
                                Image(systemName: "location")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(match.location.name)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Text(match.location.address)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Button(action: {
                            // 길찾기 기능
                            openAppleMap(to: nextMatch)
                        }) {
                            HStack {
                                Image(systemName: "point.topright.arrow.triangle.backward.to.point.bottomleft.filled.scurvepath")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                
                                Text("길찾기")
                                    .font(.headline)
                                    .foregroundColor(.white)
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
                            .foregroundColor(.gray)
                        
                        Text("다음 경기가 없습니다")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("새로운 매치에 참여해보세요!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
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
    }
    
    // MARK: - Helper Functions
    
    private func calculateDaysUntilMatch() -> String {
        guard let match = nextMatch else {
            return "경기없음"
        }
        
        let calendar = Calendar.current
        let today = Date()
        let days = calendar.dateComponents([.day], from: today, to: match.dateTime).day ?? 0
        
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
