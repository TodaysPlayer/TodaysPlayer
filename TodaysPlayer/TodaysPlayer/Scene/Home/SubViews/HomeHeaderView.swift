//
//  HomeHeaderView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct HomeHeaderView: View {
    let user: User?
    let unreadNotificationCount: Int
    let onNotificationTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘의 플레이어")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let user = user {
                        Text("안녕하세요, \(user.displayName)님!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 알림 버튼
                Button(action: onNotificationTap) {
                    ZStack {
                        Image(systemName: "bell")
                            .font(.title2)
                        
                        if unreadNotificationCount > 0 {
                            Text("\(unreadNotificationCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
}
