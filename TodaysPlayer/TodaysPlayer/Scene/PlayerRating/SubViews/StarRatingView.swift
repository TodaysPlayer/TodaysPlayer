//
//  StarRatingView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/9/25.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var imageName: String
    var title: String
    let maxRating: Int = 5
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: imageName)
            
            Text(title)
            
            Spacer()
            
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(index <= rating ? .yellow.opacity(0.6) : .gray)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            rating = index
                        }
                    }
            }
        }
        .modifier(DescriptionTextStyle(opacityValue: 0.1))
    }
}
