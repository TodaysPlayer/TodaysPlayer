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
    @State private var isDeleting = false
    @State private var deleteError: String?
    @State private var showDeleteAlert = false
    @State private var showDeleteResult = false
    @State private var showLogoutAlert = false
    @State private var showLogoutResult = false
    @State private var goToLogin = false
    @State private var path = NavigationPath()
    @Environment(\.dismiss) private var dismiss
    
    private var pwEdit: some View {
        NavigationLink(destination: PwEditView()) {
            MyPageRow(icon: "key.viewfinder", iconColor: .blue, title: "비밀번호 변경", subtitle: "비밀번호를 변경할 수 있습니다.")
        }
        .padding(.horizontal)
    }
    
    private var logOut: some View {
        Button {
            showLogoutAlert = true
        } label: {
            MyPageRow(icon: "rectangle.portrait.and.arrow.right", iconColor: .orange, title: "로그아웃", subtitle: "현재 계정에서 로그아웃 합니다.")
        }
        .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) {
            }
            Button("확인", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("현재 계정에서 로그아웃합니다.")
        }
        .alert("로그아웃", isPresented: $showLogoutResult) {
            Button("확인") {
                // 로그인 화면으로 이동 - 네비게이션 스택 비우기
                while !path.isEmpty {
                    path.removeLast()
                }
                showLogoutResult = false
                goToLogin = true
            }
        } message: {
            Text("로그아웃 되었습니다.")
        }
        .padding(.horizontal)
    }
    
    private var checkOut: some View {
        Button {
            showDeleteAlert = true
        } label: {
            MyPageRow(icon: "person.slash.fill", iconColor: .red, title: "회원 탈퇴", subtitle: "모든 정보를 지우고 회원 탈퇴 합니다.")
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
            Button("확인") {
                // 로그인 화면으로 이동 - 네비게이션 스택 비우기
                while !path.isEmpty {
                    path.removeLast()
                }
                showDeleteResult = false
                goToLogin = true
            }
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
        .padding(.horizontal)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                pwEdit
                logOut
                checkOut
            }
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("계정 관리")
                        .font(.title2)
                        .bold()
                }
            }
            .fullScreenCover(isPresented: $goToLogin) {
                LoginView()
                    .interactiveDismissDisabled(true)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .background(Color.gray.opacity(0.1))
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
                        // 네비게이션 스택 비우기
                        while !path.isEmpty {
                            path.removeLast()
                        }
                        self.showDeleteResult = true
                    }
                }
            }
        }
    }
    private func performLogout() {
        do {
            try Auth.auth().signOut()
            // 네비게이션 스택 비우기
            while !path.isEmpty {
                path.removeLast()
            }
            // 확인 알림 표시
            self.showLogoutAlert = false
            self.showLogoutResult = true
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
            self.showLogoutAlert = false
        }
    }
}


#Preview {
    AccountView()
}
