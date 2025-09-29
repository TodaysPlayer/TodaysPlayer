//
//  MatchSectionView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct MatchSectionView: View {
    let title: String
    let matches: [Match]
    let showCount: Bool
    let isHorizontal: Bool
    let onApply: (String) -> Void
    let onMoreTap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if showCount {
                    Text("\(matches.count)개")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if let onMoreTap = onMoreTap {
                    Button("더보기", action: onMoreTap)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if isHorizontal {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(matches.prefix(5)) { match in
                            MatchCardView(match: match) {
                                onApply(match.id)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, -24)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(matches) { match in
                        MatchCardView(match: match) {
                            onApply(match.id)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
}
