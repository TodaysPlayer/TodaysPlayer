//
//  AnnouncementCardView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct AnnouncementCardView: View {
    let announcement: Announcement
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(announcement.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    if announcement.isImportant {
                        Text("중요")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
                
                Text(announcement.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 8) {
        AnnouncementCardView(
            announcement: Announcement(
                id: "announce1",
                title: "앱 업데이트 안내",
                content: "새로운 기능이 추가되었습니다. 자세한 내용은 설정에서 확인해주세요.",
                isImportant: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        
        AnnouncementCardView(
            announcement: Announcement(
                id: "announce2",
                title: "매치 등록 가이드",
                content: "매치 등록 시 주의사항을 안내드립니다.",
                isImportant: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    }
    .padding()
}
