//
//  NextMatchCard.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct NextMatchCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("골린이")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            
                            Text("님")
                                .font(.system(size: 16))
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                        }
                        
                        Text("최근 경기 정보를 알려드릴게요~!")
                            .font(.subheadline)
                            .font(.system(size: 16))
                            .padding(.top, 1)
                    }
                    
                    Spacer()
                    
                    Text("D-1")
                        .font(.system(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
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
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            
                            Text("내일 19:00")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        HStack(alignment: .center) {
                            Image(systemName: "location")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("서울풋살파크")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Text("강남구 테헤란로 123")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Button(action: {
                        // 길찾기 기능
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
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NextMatchCard()
}
