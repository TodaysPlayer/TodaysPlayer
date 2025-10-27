//
//  MatchDetailComponents.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/13/25.
//
//  상세화면에서 공유하는 컴포넌트들

import SwiftUI

// MARK: - 헤더 컴포넌트
struct MatchDetailHeaderView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
        }
    }
}

// MARK: - 정보 아이템
struct InfoItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 설명 섹션
struct MatchDescriptionSection: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "설명")
            
            Text(description)
                .font(.body)
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
    }
}

// MARK: - 섹션 헤더
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.top, 8)
    }
}

// MARK: - 주의사항
struct WarningNoticeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "주의사항")
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text("날씨가 좋지 않을 경우에만 매칭 취소 예외입니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - 주최자 정보
struct OrganizerInfoView: View {
    let name: String
    let imageURL: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "주최자 정보")
            
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("매칭 주최자입니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}
