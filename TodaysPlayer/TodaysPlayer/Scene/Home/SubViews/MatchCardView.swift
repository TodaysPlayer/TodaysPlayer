//
//  MatchCardView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct MatchCardView: View {
    let match: Match
    let onApply: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(match.location.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("₩\(match.price)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Label(match.skillLevel, systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Label(match.matchType == "team" ? "팀" : "개인", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            HStack {
                Label(formatDate(match.dateTime), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("신청하기", action: onApply)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
}
