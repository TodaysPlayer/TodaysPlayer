//
//  SettingView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AccountView: View {
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var deleteError: String?
    @State private var showDeleteResult = false
    
    private var pwEdit: some View {
        NavigationLink(destination: PwEditView()) {
            MyPageRowView(icon: "key.viewfinder", iconColor: .blue, title: "비밀번호 변경", subtitle: "비밀번호를 변경할 수 있습니다.")
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                pwEdit
            }
        }
        
        
        Button {
            showDeleteAlert = true
        } label: {
            MyPageRowView(icon: "person.slash.fill", iconColor: .red, title: "회원 탈퇴", subtitle: "회원 탈퇴 합니다.")
        }
        .alert("정말 탈퇴하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("탈퇴", role: .destructive) {
                performAccountDeletion()
            }
        } message: {
            Text("모든 데이터가 삭제됩니다.")
        }
        // 계정 삭제 완료
        .alert("계정 삭제 완료", isPresented: $showDeleteResult) {
            Button("확인") { }
        } message: {
            Text("그동안 이용해주셔서 감사합니다.")
        }
        // 계정 삭제 실패
        .alert("계정 삭제 실패", isPresented: Binding(get: { deleteError != nil }, set: { if !$0 { deleteError = nil } })) {
            Button("확인") { }
        } message: {
            Text(deleteError ?? "알 수 없는 오류가 발생했습니다.")
        }
        .disabled(isDeleting)
        .overlay {
            if isDeleting {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView("탈퇴 처리 중...")
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func performAccountDeletion() {
        // 닫고 진행 시작
        showDeleteAlert = false
        isDeleting = true
        
        guard let user = Auth.auth().currentUser else {
            isDeleting = false
            deleteError = "로그인된 사용자가 없습니다."
            return
        }
        
        let uid = user.uid
        let db = Firestore.firestore()
        
        // 1) Firestore 사용자 문서 삭제 (필요 시 다른 컬렉션/서브컬렉션도 함께 정리)
        db.collection("users").document(uid).delete { err in
            if let err = err {
                DispatchQueue.main.async {
                    self.isDeleting = false
                    self.deleteError = "데이터 삭제 실패: \(err.localizedDescription)"
                }
                return
            }
            
            // 2) Firebase Auth 계정 삭제
            user.delete { error in
                DispatchQueue.main.async {
                    self.isDeleting = false
                    if let error = error as NSError? {
                        if let code = AuthErrorCode(rawValue: error.code), code == .requiresRecentLogin {
                            self.deleteError = "보안을 위해 최근에 다시 로그인해야 합니다. 재로그인 후 다시 시도해주세요."
                        } else {
                            self.deleteError = "계정 삭제 실패: \(error.localizedDescription)"
                        }
                    } else {
                        // 3) 로컬 세션 정리
                        _ = try? Auth.auth().signOut()
                        self.showDeleteResult = true
                    }
                }
            }
        }
    }
}


#Preview {
    AccountView()
}

