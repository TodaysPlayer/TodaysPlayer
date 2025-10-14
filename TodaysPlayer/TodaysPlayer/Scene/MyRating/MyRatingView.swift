//
//  MyRatingView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/11/25.
//

import SwiftUI

struct MyRatingView: View {
    let userRating: UserRating = UserRating(
        userId: "",
        totalRatingCount: 12,
        mannerSum: 60,
        teamWorkSum: 49,
        appointmentSum: 50
    )
    
    var body: some View {
        VStack(spacing: 20) {
            TotalAvgRatingView(userInfo: userRating)
                .padding(.bottom)
            
            RatingSectionView(userInfo: userRating)
                .padding(.bottom)
            
            MyRatingPageDescriptionView()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .ignoresSafeArea()

    }
}

#Preview {
    MyRatingView()
}
