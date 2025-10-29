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
    @State private var showDeletionCompletionAlert = false
    @Environment(\.dismiss) private var dismiss
    private let authManager: AuthManager = AuthManager()
    
    private var pwEdit: some View {
        NavigationLink(destination: PwEditView()) {
            MyPageRow(icon: "key.viewfinder", iconColor: .primaryBaseGreen, title: "비밀번호 변경", subtitle: "비밀번호를 변경할 수 있습니다.")
        }
        .padding(.horizontal)
    }
    
    private var logOut: some View {
        Button {
            showSystemAlert(
                title: "로그아웃 하시겠습니까?",
                message: "현재 계정에서 로그아웃합니다.",
                tint: .systemRed, // ✅ alert 버튼만 빨간색
                actions: [
                    UIAlertAction(title: "취소", style: .cancel),
                    UIAlertAction(title: "확인", style: .destructive) { _ in
                        performLogout()
                    }
                ]
            )
        } label: {
            MyPageRow(icon: "rectangle.portrait.and.arrow.right",
                      iconColor: .accentOrange,
                      title: "로그아웃",
                      subtitle: "현재 계정에서 로그아웃 합니다.")
        }
        .padding(.horizontal)
    }
    
    private var checkOut: some View {
        Button {
            showSystemAlert(
                title: "정말 탈퇴하시겠습니까?",
                message: "모든 데이터가 삭제됩니다.",
                tint: .systemRed, // ✅ 탈퇴 Alert는 빨간색 버튼
                actions: [
                    UIAlertAction(title: "취소", style: .cancel),
                    UIAlertAction(title: "탈퇴", style: .destructive) { _ in
                        performAccountDeletion()
                    }
                ]
            )
        } label: {
            MyPageRow(
                icon: "person.slash.fill",
                iconColor: .accentRed,
                title: "회원 탈퇴",
                subtitle: "모든 정보를 지우고 회원 탈퇴 합니다."
            )
        }
        .disabled(isDeleting)
        .padding(.horizontal)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                ScrollView {
                    pwEdit
                    logOut
                    checkOut
                }
                if isDeleting {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView("탈퇴 처리 중...")
                        .padding(16)
                        .background(Color.secondaryCoolGray)
                        .cornerRadius(20)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("계정 관리")
                        .font(.title2)
                        .bold()
                }
            }
            .background(Color.gray.opacity(0.1))
            .foregroundStyle(Color(.black))
        }
        .fullScreenCover(isPresented: $goToLogin) {
            LoginView()
                .interactiveDismissDisabled(true)
                .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func performAccountDeletion() {
        // 닫고 진행 시작
        showDeleteAlert = false
        isDeleting = true
        
        guard let user = Auth.auth().currentUser else {
            isDeleting = false
            deleteError = "로그인된 사용자가 없습니다."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                ToastManager.shared.show(title: "계정 삭제 실패",
                                         message: self.deleteError ?? "알 수 없는 오류가 발생했습니다.",
                                         buttonTitle: "확인") {
                    while !self.path.isEmpty { self.path.removeLast() }
                    self.goToLogin = true
                }
            }
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        ToastManager.shared.show(title: "계정 삭제 실패",
                                                 message: self.deleteError ?? "알 수 없는 오류가 발생했습니다.",
                                                 buttonTitle: "확인") {
                            while !self.path.isEmpty { self.path.removeLast() }
                            self.goToLogin = true
                        }
                    }
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            ToastManager.shared.show(title: "계정 삭제 실패",
                                                     message: self.deleteError ?? "알 수 없는 오류가 발생했습니다.",
                                                     buttonTitle: "확인") {
                                while !self.path.isEmpty { self.path.removeLast() }
                                self.goToLogin = true
                            }
                        }
                    } else {
                        _ = try? Auth.auth().signOut()
                        UserSessionManager.shared.removeSeesion()
                        self.deleteError = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            ToastManager.shared.show(title: "계정 삭제 완료",
                                                     message: "그동안 이용해주셔서 감사합니다.",
                                                     buttonTitle: "확인") {
                                while !self.path.isEmpty { self.path.removeLast() }
                                self.goToLogin = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func performLogout() {
            authManager.logout()
            // 네비게이션 스택 비우기
            while !path.isEmpty {
                path.removeLast()
            }
            // 확인 알림 표시
            self.showLogoutAlert = false
            ToastManager.shared.show(title: "로그아웃 완료",
                                     message: "성공적으로 로그아웃되었습니다.",
                                     buttonTitle: "확인") {
                while !self.path.isEmpty { self.path.removeLast() }
                self.goToLogin = true
            }
    }
}

    extension View {
            func showSystemAlert(title: String,
                         message: String,
                         tint: UIColor = .systemBlue,
                         actions: [UIAlertAction] = []) {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let window = scene.windows.first,
                        let rootVC = window.rootViewController else { return }
        
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.view.tintColor = tint // ✅ 이게 핵심 (alert별로 색 지정 가능)
        
        // 전달된 액션이 있으면 추가하고, 없으면 기본 OK 버튼 추가
                if actions.isEmpty {
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                } else {
                actions.forEach { alert.addAction($0) }
                }
        
                rootVC.present(alert, animated: true)
    }
}

#Preview {
    AccountView()
}
