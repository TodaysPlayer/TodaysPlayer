//
//  MyRatingView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/11/25.
//

import SwiftUI

struct UserRating {
    let userId: String
    var totalRatingCount: Int
    var mannerSum: Double
    var teamWorkSum: Double
    var appointmentSum: Double
}

struct TotalAvgRatingView: View {
    let userInfo: UserRating
    var avgRating: Double
    
    init(userInfo: UserRating) {
        self.userInfo = userInfo
        let count = Double(max(userInfo.totalRatingCount, 1))
        self.avgRating = (userInfo.appointmentSum + userInfo.mannerSum + userInfo.teamWorkSum) / (count * 3)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "rosette")
                .font(.largeTitle)
                .foregroundColor(.black)
            
            HStack(spacing: 10) {
                Text(String(format: "%.1f", avgRating))
                    .font(.title2)
                    .bold()
                
                Text("/ 5.0")
                    .foregroundColor(.gray)
            }
            
            Text("총 \(userInfo.totalRatingCount)개의 평가")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}


struct RatingSectionView: View {
    let userInfo: UserRating
    var ratingList: [(String, String, score: Double)]

    init(userInfo: UserRating) {
        self.userInfo = userInfo
        
        let count = Double(userInfo.totalRatingCount)
        
        self.ratingList = [
            ("heart", "매너", userInfo.mannerSum / count),
            ("person.2", "팀워크", userInfo.teamWorkSum / count),
            ("timer", "시간약속", userInfo.appointmentSum / count)
        ]
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("세부 평가")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(ratingList, id: \.1) { imageName, title, value in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: imageName)
                            .foregroundColor(.green)
                        
                        Text(title)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f점", value))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    ProgressView(value: value, total: 1.0)
                        .tint(.green)
                        .frame(height: 8)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1, y: 1)
    }
}

struct MyRatingView: View {
    let matchInfo: MatchInfo
    let userRating: UserRating = UserRating(userId: "", totalRatingCount: 12, mannerSum: 60, teamWorkSum: 49, appointmentSum: 50)
    
    var body: some View {
        VStack {
            TotalAvgRatingView(userInfo: userRating)
                .padding(.bottom)
            RatingSectionView(userInfo: userRating)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .ignoresSafeArea()

    }
}

#Preview {
    MyRatingView(matchInfo: mockMatchData.first!)
}
