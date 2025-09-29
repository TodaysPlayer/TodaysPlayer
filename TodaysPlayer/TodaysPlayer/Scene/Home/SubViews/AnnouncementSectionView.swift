//
//  AnnouncementSectionView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct AnnouncementSectionView: View {
    let announcements: [Announcement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("공지사항")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(announcements.prefix(3)) { announcement in
                    AnnouncementCardView(announcement: announcement)
                }
            }
        }
    }
}

#Preview {
    AnnouncementSectionView(
        announcements: [
            Announcement(
                id: "announce1",
                title: "앱 업데이트 안내",
                content: "새로운 기능이 추가되었습니다.",
                isImportant: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    )
}
