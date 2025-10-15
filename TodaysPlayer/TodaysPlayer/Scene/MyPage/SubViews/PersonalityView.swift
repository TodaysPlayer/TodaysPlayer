//
//  PersonalityView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI

struct PersonalityView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero banner
                Card {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("저희 풋살/축구 매칭 플랫폼 '오늘의 용병'은 이용자의 개인정보를 소중히 생각하며, 개인정보 보호법을 준수하여 안전하게 관리하고 있습니다.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 1) {
                                Label("최종 업데이트: \n2025년 10월 15일", systemImage: "calendar")
                                Spacer()
                                Label("시행일: \n2025년 10월 10일", systemImage: "clock")
                            }
                            .labelStyle(.titleAndIcon)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                }
                .padding(.horizontal)

                // Section 1
                CardSection(title: "1. 개인정보의 수집 및 이용 목적") {
                    VStack(alignment: .leading, spacing: 10) {
                        GroupBoxLabel(title: "회원 관리")
                        BulletList(items: [
                            "회원제 서비스 이용에 따른 본인확인, 계정식별",
                            "부정 이용 방지, 비정상 사용 탐지",
                            "서비스 이용 현황 파악"
                        ])
                        Divider().padding(.vertical, 4)
                        GroupBoxLabel(title: "서비스 제공")
                        BulletList(items: [
                            "풋살/축구 경기 매칭 서비스 제공",
                            "향상된 매칭 품질과 서비스를 제공",
                            "설문 및 피드백을 통한 서비스 개선",
                            "알림/푸시, 공지 사항 제공"
                        ])
                    }
                }
                .padding(.horizontal)

                // Section 2 (수집 항목 예시)
                CardSection(title: "2. 수집하는 개인정보 항목") {
                    BulletList(items: [
                        "이메일, 닉네임",
                        "기기 정보(OS 버전, 디바이스 모델)",
                        "서비스 이용 기록, 접속 로그, 쿠키 등"
                    ])
                }
                .padding(.horizontal)

                // Section 3 보유 기간
                CardSection(title: "3. 보유 및 이용 기간") {
                    Text("회원 탈퇴 시 지체 없이 파기하며, 관련 법령에 따라 일정 기간 보관이 필요한 경우 해당 기간 동안 보관합니다.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.horizontal)

                // Section 4 제3자 제공/처리위탁
                CardSection(title: "4. 제3자 제공 및 처리위탁") {
                    Text("원칙적으로 동의 없이 제공하지 않으며, 필요한 경우 수탁자, 목적, 기간을 고지합니다.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.horizontal)

                // Section 5 위탁업체 표
                CardSection(title: "5. 개인정보 처리 위탁") {
                    SimpleTable(headers: ["위탁업체", "위탁업무"], rows: [
                        ["Amazon Web Services", "클라우드 서버 운영"],
                        ["Firebase", "푸시 알림 서비스"],
                        ["이니시스", "결제 서비스"]
                    ])
                }
                .padding(.horizontal)

                // Section 6 권리
                CardSection(title: "6. 이용자의 권리") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("이용자는 언제든지 다음과 같은 권리를 행사할 수 있습니다.")
                            .font(.subheadline)
                        BulletList(items: [
                            "개인정보 열람 요구",
                            "오류 등이 있을 경우 정정·삭제 요구",
                            "처리정지 요구",
                            "개인정보보호 담당자에게 서면, 전화, 이메일로 연락"
                        ])
                    }
                }
                .padding(.horizontal)

                // Section 7 담당자
                CardSection(title: "7. 개인정보보호 담당자") {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("개인정보 보호 담당자").font(.subheadline.weight(.semibold))
                            Text("성명: 김개인 / 직책: 개인정보보호책임자")
                            Text("연락처: privacy@futsalmatch.com")
                        }
                        .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("개인정보보호 담당부서").font(.subheadline.weight(.semibold))
                            Text("부서명: 개인정보보호팀")
                            Text("연락처: 1588-1234")
                        }
                        .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal)

                // Section 8 변경 이력
                CardSection(title: "개인정보 처리방침 변경 이력") {
                    VStack(alignment: .leading, spacing: 10) {
                        ChangeLogItem(version: "버전 2.0", desc: "개인정보 수집 항목 추가, 위탁업체 정보 업데이트", date: "2025.10.14")
                        ChangeLogItem(version: "버전 1.1", desc: "개인정보 보유기간 명시, 제3자 제공 조항 수정", date: "2025.10.01")
                        ChangeLogItem(version: "버전 1.0", desc: "최초 제정", date: "2025.09.24")
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 24)
            }
            .padding(.vertical, 12)
        }
        .navigationTitle("개인정보 처리방침")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("닫기") { dismiss() }
            }
        }
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Components

private struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            content
        }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white, lineWidth: 1)
            )
    }
}

private struct CardSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                HStack {
                    content
                    Spacer()
                }
            }
        }
    }
}

private struct GroupBoxLabel: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
    }
}

private struct BulletList: View {
    let items: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(item)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
    }
}

private struct SimpleTable: View {
    let headers: [String]
    let rows: [[String]]
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(headers.indices, id: \.self) { idx in
                    Text(headers[idx])
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: idx == 0 ? .leading : .center)
                }
            }
            .padding(.vertical, 8)
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color.black.opacity(0.06)), alignment: .bottom)

            ForEach(rows, id: \.self) { row in
                HStack(alignment: .top) {
                    Text(row.first ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.dropFirst().first ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
                .overlay(Rectangle().frame(height: 1).foregroundColor(Color.black.opacity(0.06)), alignment: .bottom)
            }
        }
    }
}

private struct ChangeLogItem: View {
    let version: String
    let desc: String
    let date: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(version).font(.subheadline.weight(.semibold))
                Text(desc).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text(date).font(.footnote).foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack { PersonalityView() }
}
