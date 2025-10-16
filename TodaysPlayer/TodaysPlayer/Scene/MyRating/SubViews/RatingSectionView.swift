//
//  RatingSectionView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/13/25.
//

import SwiftUI

struct RatingSectionView: View {
    private var userInfo: UserRating? = nil
    private var ratingList: [(String, String, score: Double)]

    init(userInfo: UserRating? = nil) {
        self.userInfo = userInfo
        
        let count = Double(userInfo?.totalRatingCount ?? 0)
        
        self.ratingList = [
            ("heart", "매너", (userInfo?.mannerSum ?? 0) / count),
            ("person.2", "팀워크", (userInfo?.teamWorkSum ?? 0) / count),
            ("timer", "시간약속", (userInfo?.appointmentSum ?? 0) / count)
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
                    
                    ProgressView(value: value / 5.0, total: 1.0)
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
