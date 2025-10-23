//
//  QuestionView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI

private enum InquiryType: String, CaseIterable, Identifiable {
    case account = "계정/로그인"
    case payment = "결제/환불"
    case match = "경기/매치"
    case bug = "버그 제보"
    case feedback = "개선 제안"
    case other = "기타"

    var id: String { rawValue }
    var title: String { rawValue }
}

struct QuestionView: View {
    // MARK: - State
    @Environment(\.dismiss) private var dismiss

    @State private var inquiryType: InquiryType? = nil
    @State private var subject: String = ""
    @State private var bodyText: String = ""
    @State private var contactEmail: String = ""

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    let faqs: [FAQItem]
    init(faqs: [FAQItem] = FAQItem.faqs) {
        self.faqs = faqs
    }
    // MARK: - Layout
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                inquiryCard
                faqSection
                contactSection
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("운영자에게 문의하기")
                    .font(.title2)
                    .bold()
            }
        }
        .alert("알림", isPresented: $showAlert, actions: {
            Button("확인", role: .cancel) {}
        }, message: {
            Text(alertMessage)
        })
    }

    // MARK: - Sections
    private var inquiryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 문의 유형
            LabeledContainer(label: "문의 유형") {
                Menu {
                    ForEach(InquiryType.allCases) { type in
                        Button(type.title) { inquiryType = type }
                    }
                } label: {
                    HStack {
                        Text(inquiryType?.title ?? "문의 유형을 선택해주세요")
                            .foregroundColor(inquiryType == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }

            // 제목
            LabeledContainer(label: "제목") {
                TextField("문의 제목을 입력해주세요", text: $subject)
                    .textInputAutocapitalization(.sentences)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            // 문의 내용
            LabeledContainer(label: "문의 내용") {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $bodyText)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(fieldBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    if bodyText.isEmpty {
                        Text("문의하실 내용을 자세히 작성해주세요. 문제 상황, 발생 시간, 사용 환경 등을 포함해주시면 더 빠른 답변이 가능합니다.")
                            .foregroundColor(.secondary)
                            .padding(.top, 15)
                            .padding(.horizontal, 12)
                            .allowsHitTesting(false)
                    }
                }
            }

            // 이메일
            LabeledContainer(label: "연락받을 이메일") {
                TextField("example@email.com", text: $contactEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            // 전송 버튼
            Button(action: sendInquiry) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("문의 보내기")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.green)) // dark on light, adapts
                .clipShape(RoundedRectangle(cornerRadius: 40))
            }
            .buttonStyle(.plain)
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.5)
        }
        .padding(16)
        .background(Color.white)
        .toolbar(.hidden, for: .tabBar)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("자주 묻는 질문")
                .font(.headline)
                .foregroundColor(.primary)
            VStack(spacing: 10) {
                ForEach(faqs) { item in
                    FAQCard(item: item)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("연락처 정보")
                .font(.headline)
            ContactRow(icon: "envelope.fill", title: "이메일", detail: "support@futsalmatch.com")
            ContactRow(icon: "phone.fill", title: "고객센터", detail: "1588-1234 (평일 09:00~18:00)")
            ContactRow(icon: "clock.fill", title: "운영시간", detail: "평일 09:00~18:00 (주말 및 공휴일 제외)")
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Helpers
    private var fieldBackground: Color { Color.gray.opacity(0.12) }

    private var isFormValid: Bool {
        guard let inquiryType else { return false }
        _ = inquiryType // silence unused warning if builds strip usage
        return !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               isValidEmail(contactEmail)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.contains("@"), trimmed.contains(".") else { return false }
        return true
    }

    private func sendInquiry() {
        // Validate again just in case
        guard let inquiryType else { return }

        // Create and store the email message
        let message = EmailMessage(
            inquiryType: inquiryType.title,
            subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
            body: bodyText.trimmingCharacters(in: .whitespacesAndNewlines),
            contactEmail: contactEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        EmailCollection.shared.add(message)

        // Notify user
        alertMessage = "문의가 정상적으로 접수되었습니다. 빠른 시일 내에 답변드리겠습니다."
        showAlert = true

        // Reset fields (including contact email)
        subject = ""
        bodyText = ""
        contactEmail = ""
        // Keep inquiryType for convenience
    }
}

// MARK: - Subviews
private struct LabeledContainer<Content: View>: View {
    let label: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            content()
        }
    }
}

private struct FAQCard: View {
    let item: FAQItem
    @State private var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut) { expanded.toggle() }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Text("Q.")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(item.question)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
            .buttonStyle(.plain)

            if expanded {
                Text(item.answer)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct ContactRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(detail)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        QuestionView()
    }
}

