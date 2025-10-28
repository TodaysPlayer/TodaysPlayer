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
    private var average: (Double, Double) -> Double = { sum, count in
        guard count > 0 else { return 0 }
        return sum / count
    }

    init(userInfo: UserRating? = nil) {
        self.userInfo = userInfo
        
        let count = Double(userInfo?.totalRatingCount ?? 0)
        

        self.ratingList = [
            ("heart", "매너", average(userInfo?.mannerSum ?? 0, Double(count))),
            ("person.2", "팀워크", average(userInfo?.teamWorkSum ?? 0, Double(count))),
            ("timer", "시간약속", average(userInfo?.appointmentSum ?? 0, Double(count)))
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
                            .foregroundColor(Color.primaryBaseGreen)
                        
                        Text(title)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f점", value))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    ProgressView(value: value / 5.0, total: 1.0)
                        .tint(Color.primaryBaseGreen)
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
