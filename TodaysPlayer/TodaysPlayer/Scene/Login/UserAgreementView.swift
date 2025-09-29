//
//  UserAgreementView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/29/25.
//

import SwiftUI

struct CheckboxView: View {
    @Binding var isChecked: Bool
    var title: String
    var required: Bool = false
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .black : .gray)
                    .font(.system(size: 22))
                
                Text(title)
                    .foregroundColor(.primary)
                
                Text(required ? "(필수)" : "(선택)")
                    .foregroundColor(required ? .red : .gray)
                    .font(.caption)
                
                Spacer()
                
                Image(systemName: "eye") // 약관 보기 아이콘
                    .foregroundColor(.gray)
            }
        }
    }
}


// 약관 동의 메인뷰
struct UserAgreementView: View {
    @State private var agreeAll = false
    @State private var agreeService = false
    @State private var agreePrivacy = false
    @State private var agreeAge = false
    @State private var agreeMarketing = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 안내 문구
                Text("서비스 이용을 위한 약관에 동의해주세요")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                // 전체 동의 박스
                VStack(alignment: .leading) {
                    Button(action: {
                        agreeAll.toggle()
                        agreeService = agreeAll
                        agreePrivacy = agreeAll
                        agreeAge = agreeAll
                        agreeMarketing = agreeAll
                    }) {
                        HStack {
                            Image(systemName: agreeAll ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeAll ? .blue : .black)
                                .font(.system(size: 22))
                            
                            VStack(alignment: .leading) {
                                Text("전체 동의")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text("선택항목에 대한 동의 포함")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 개별 항목 체크박스
                Group {
                    CheckboxView(isChecked: $agreeService, title: "서비스 이용약관 동의", required: true)
                    CheckboxView(isChecked: $agreePrivacy, title: "개인정보 수집 및 이용 동의", required: true)
                    CheckboxView(isChecked: $agreeAge, title: "만 14세 이상입니다", required: true)
                    CheckboxView(isChecked: $agreeMarketing, title: "마케팅 정보 수신 동의", required: false)
                }
                .padding(.horizontal)
                
                // 약관 주요 내용 안내 박스
                VStack(alignment: .leading, spacing: 8) {
                    Text("서비스 이용약관 주요 내용:")
                        .font(.subheadline)
                        .bold()
                    Text("• 서비스 이용 시 준수사항")
                    Text("• 사용자의 권리와 의무")
                    Text("• 서비스 제공자의 권리와 의무")
                    Text("• 서비스 이용 제한 및 중단")
                }
                .font(.caption)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // 하단 버튼
                Button(action: {
                    print("약관 동의 완료")
                }) {
                    Text("필수 약관에 동의해주세요")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(allRequiredAgreed ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(!allRequiredAgreed)
            }
            .navigationTitle("약관 동의")
        }
    }
    
    // 필수 항목 모두 체크됐는지 확인
    private var allRequiredAgreed: Bool {
        agreeService && agreePrivacy && agreeAge
    }
}

// 미리보기
struct UserAgreementView_Previews: PreviewProvider {
    static var previews: some View {
        UserAgreementView()
    }
}
