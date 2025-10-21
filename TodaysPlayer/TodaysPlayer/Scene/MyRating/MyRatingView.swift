//
//  MyRatingView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/11/25.
//

import SwiftUI

struct MyRatingView: View {
    
    let viewModel: MyRatingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            TotalAvgRatingView(
                userInfo: viewModel.userData?.userRate,
                avgRating: viewModel.avgRating()
            )
                .padding(.bottom)
            
            RatingSectionView(userInfo: viewModel.userData?.userRate)
                .padding(.bottom)
            
            MyRatingPageDescriptionView()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }
}
