//
//  AnnouncementView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import Foundation

struct AnnouncementView: View {
    // 별도 파일의 데이터를 사용합니다. 필요 시 주입 가능하도록 기본값 제공
    let announcements: [AnnouncementList]
    @State private var expandedIDs: Set<UUID> = []

    init(announcements: [AnnouncementList] = AnnouncementList.samples) {
        self.announcements = announcements
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(announcements) { item in
                    AnnouncementCard(
                        item: item,
                        isExpanded: expandedIDs.contains(item.id)
                    ) {
                        toggle(item)
                    }
                    .animation(.snappy, value: expandedIDs)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("공지사항")
    }

    private func toggle(_ item: AnnouncementList) {
        if expandedIDs.contains(item.id) {
            expandedIDs.remove(item.id)
        } else {
            expandedIDs.insert(item.id)
        }
    }
}

private struct AnnouncementCard: View {
    let item: AnnouncementList
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundStyle(.secondary)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .contentShape(Rectangle())
            .padding(16)
            .onTapGesture(perform: onTap)

            if isExpanded {
                Divider()
                Text(item.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        AnnouncementView()
    }
}
