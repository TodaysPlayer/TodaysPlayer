//
//  UserAgreementView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/29/25.
//

import SwiftUI

enum AgreeSessionURL: String, CaseIterable {
    case serviceTerms
    case privacyPolicy
    case marketingConsent
    
    /// 각 항목별 외부 링크 URL
    var url: URL? {
        switch self {
        case .serviceTerms:
            return URL(string: "https://www.notion.so/29bdb27feebd8065bf50de6cc94a34fc?source=copy_link")
        case .privacyPolicy:
            return URL(string: "https://www.notion.so/29bdb27feebd80ff9c92fdb5a6c509f3?source=copy_link")
        case .marketingConsent:
            return URL(string: "https://www.notion.so/29bdb27feebd80c39a2becf603499502?source=copy_link")
        }
    }
    
    /// 표시용 이름 (UI 텍스트에 사용)
    var displayName: String {
        switch self {
        case .serviceTerms:
            return "서비스 이용약관"
        case .privacyPolicy:
            return "개인정보 처리방침"
        case .marketingConsent:
            return "마케팅 수신 동의"
        }
    }
}

struct CheckboxView: View {
    @Binding var isChecked: Bool
    var title: String
    var required: Bool = false
    var linkURL: URL? = nil

    var body: some View {
        HStack {
            Button {
                isChecked.toggle()
            } label: {
                HStack {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .foregroundColor(isChecked ? .primaryBaseGreen : .gray)
                        .font(.system(size: 22))
                    
                    Text(title)
                        .foregroundColor(.primary)
                    
                    Text(required ? "(필수)" : "(선택)")
                        .foregroundColor(required ? .accentRed : .gray)
                        .font(.caption)
                }
            }
            
            Spacer()
            
            if let url = linkURL {
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    HStack(spacing: 4) {
                        Text("자세히보기")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}


struct UserAgreementView: View {
    @State private var agreeAll = false
    @State private var agreeService = false
    @State private var agreePrivacy = false
    @State private var agreeAge = false
    @State private var agreeMarketing = false
    
    @State private var goToSignUp = false
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("서비스 이용을 위한 약관에 동의해주세요")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            
            // 전체 동의
            Button {
                agreeAll.toggle()
                
                // 전체 동의 true → 모두 true / false → 모두 false
                agreeService = agreeAll
                agreePrivacy = agreeAll
                agreeMarketing = agreeAll
            } label: {
                HStack {
                    Image(systemName: agreeAll ? "checkmark.square.fill" : "square")
                        .foregroundColor(agreeAll ? .primaryBaseGreen : .gray)
                        .font(.system(size: 22))
                    
                    Text("전체 동의")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding()
                .background(Color.secondaryDeepGray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // 개별 항목
            VStack(alignment: .leading, spacing: 16) {
                CheckboxView(
                    isChecked: $agreeService,
                    title: AgreeSessionURL.serviceTerms.displayName,
                    required: true,
                    linkURL: AgreeSessionURL.serviceTerms.url
                )
                
                CheckboxView(
                    isChecked: $agreePrivacy,
                    title: AgreeSessionURL.privacyPolicy.displayName,
                    required: true,
                    linkURL: AgreeSessionURL.privacyPolicy.url
                )
                
                CheckboxView(
                    isChecked: $agreeMarketing,
                    title: AgreeSessionURL.marketingConsent.displayName,
                    linkURL: AgreeSessionURL.marketingConsent.url
                )
                
            }
            .onChange(of: [agreeService, agreePrivacy, agreeAge, agreeMarketing]) { _, _ in
                updateAgreeAllState()
            }
            .padding(.leading, 30)
            .padding(.trailing, 10)
            
            Spacer()
            
            // 다음 버튼
            Button {
                if allRequiredAgreed {
                    goToSignUp = true
                }
            } label: {
                Text("다음")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(allRequiredAgreed ? Color.primaryBaseGreen : Color.secondaryCoolGray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(!allRequiredAgreed)
        }
        .background(Color.gray.opacity(0.1))
        .navigationTitle("약관 동의")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToSignUp) {
            SignUpView(path: $path)
        }
    }
    
    // 개별 항목이 모두 선택되었는지 검사
    private func updateAgreeAllState() {
        agreeAll = agreeService && agreePrivacy
        
    }
    
    private var allRequiredAgreed: Bool {
        agreeService && agreePrivacy 
    }
}


// 미리보기
struct UserAgreementView_Previews: PreviewProvider {
    static var previews: some View {
        @State var path = NavigationPath()
        UserAgreementView(path: $path)
    }
}
