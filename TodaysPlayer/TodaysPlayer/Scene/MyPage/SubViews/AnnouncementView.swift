//
//  AnnouncementView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import FirebaseFirestore

struct AnnouncementView: View {
    // 공지 목록
    @State private var items: [Announcement] = []
    @State private var expandedIDs: Set<String> = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    private let service = AnnouncementService()

    var body: some View {
        ZStack {
            // 내용
            ScrollView {
                LazyVStack(spacing: 12) {
                    if items.isEmpty {
                        // 빈 상태 표시
                        emptyState
                            .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
                    } else {
                        ForEach(items, id: \.id) { item in
                            AnnouncementCard(
                                item: item,
                                isExpanded: expandedIDs.contains(expansionKey(for: item))
                            ) {
                                toggleExpansion(for: item)
                            }
                            .animation(.easeInOut(duration: 0.2), value: expandedIDs)
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        }
                    }
                }
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            }
            .background(Color.gray.opacity(0.1))
            .refreshable {
                await refresh()
            }
            .task {
                await initialLoad()
            }

            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            if let errorMessage, !errorMessage.isEmpty {
                VStack(spacing: 12) {
                    Text("불러오는 중 오류가 발생했어요")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("다시 시도") {
                        Task { await refresh() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.systemBackground)))
                .shadow(radius: 8)
                .padding()
            }
        }
        .navigationTitle("공지사항")
    }
    
    private func expansionKey(for item: Announcement) -> String {
        // 확장 상태 키를 문자열로 통일
        let mirror = Mirror(reflecting: item)
        if let child = mirror.children.first(where: { $0.label == "id" }) {
            if let s = child.value as? String { return s }
            if let u = child.value as? UUID { return u.uuidString }
        }
        // 예비 키: 제목 사용
        return item.title
    }

    private func toggleExpansion(for item: Announcement) {
        let key = expansionKey(for: item)
        if expandedIDs.contains(key) {
            expandedIDs.remove(key)
        } else {
            expandedIDs.insert(key)
        }
    }

    private func initialLoad() async {
        if items.isEmpty {
            await refresh()
        }
    }

    private func refresh() async {
        await fetchAnnouncements()
    }

    private func fetchAnnouncements() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            let decoded = try await service.fetch()
            await MainActor.run {
                self.items = decoded
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

private struct AnnouncementCard: View {
    let item: Announcement
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
                .fill(Color(.white))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
        )
    }
}

private var emptyState: some View {
    VStack(spacing: 8) {
        Image(systemName: "megaphone")
            .font(.system(size: 32))
            .foregroundStyle(.secondary)
        Text("표시할 공지사항이 없습니다")
            .font(.headline)
            .foregroundStyle(.secondary)
        Text("아래로 당겨서 새로고침 해보세요")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        // NOTE: 앱 실행 시 실제 서버에서 로드됩니다. 프리뷰는 네트워크 신뢰성이 낮을 수 있어요.
        AnnouncementView()
    }
}
