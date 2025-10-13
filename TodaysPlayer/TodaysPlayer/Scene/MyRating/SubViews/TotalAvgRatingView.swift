//
//  TotalAvgRatingView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/13/25.
//

import SwiftUI

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
            
            Text("나의 평군 점수")
                .padding(.top, 10)
            
            HStack(alignment: .center, spacing: 10) {
                Text(String(format: "%.1f", avgRating))
                    .font(.title)
                    .bold()
                
                Text("/ 5.0")
                    .foregroundColor(.gray)
            }
            
            Text("총 \(userInfo.totalRatingCount)개의 평가")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1, y: 1)
        
    }
}
