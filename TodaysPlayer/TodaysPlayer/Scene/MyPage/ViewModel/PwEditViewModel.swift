import SwiftUI
import Observation
import FirebaseAuth

@Observable
class PwEditViewModel {
    // MARK: - Inputs
    var currentPassword: String = ""
    var newPassword: String = ""
    var confirmPassword: String = ""

    // MARK: - Error Messages
    var currentPasswordError: String?
    var newPasswordError: String?
    var confirmPasswordError: String?
    var generalError: String?

    // MARK: - UI State
    var isLoading: Bool = false
    var showSuccessAlert: Bool = false

    // MARK: - Validation
    var isFormValid: Bool {
        let trimmedCurrent = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNew = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedCurrent.isEmpty &&
               trimmedNew.count >= 6 &&
               trimmedNew == trimmedConfirm &&
               trimmedNew != trimmedCurrent
    }

    func validateLocally() {
        // 현재 비밀번호
        currentPasswordError = currentPassword.isEmpty ? "현재 비밀번호를 입력해주세요." : nil

        // 새 비밀번호
        if newPassword.isEmpty {
            newPasswordError = "새 비밀번호를 입력해주세요."
        } else if newPassword.count < 8 {
            newPasswordError = "새 비밀번호는 8자 이상이어야 합니다."
        } else if newPassword == currentPassword {
            newPasswordError = "새 비밀번호가 기존 비밀번호와 같습니다."
        } else {
            newPasswordError = nil
        }

        // 새 비밀번호 확인
        if confirmPassword.isEmpty {
            confirmPasswordError = "새 비밀번호를 다시 입력해주세요."
        } else if confirmPassword != newPassword {
            confirmPasswordError = "새 비밀번호 확인이 일치하지 않습니다."
        } else {
            confirmPasswordError = nil
        }
    }

    // MARK: - Actions
    func changePassword() {
        // 초기화 및 로컬 검증
        generalError = nil
        validateLocally()
        guard isFormValid else { return }

        guard let user = Auth.auth().currentUser, let email = user.email else {
            generalError = "로그인 정보가 없습니다. 다시 로그인해주세요."
            return
        }

        isLoading = true

        // Firebase는 저장된 비밀번호를 직접 제공하지 않으므로, 재인증으로 현재 비밀번호를 검증합니다.
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                self.isLoading = false
                // 재인증 실패 => 현재 비밀번호가 올바르지 않음
                self.currentPasswordError = "현재 비밀번호가 올바르지 않습니다."

                // Firebase의 내부 에러 메시지는 사용자에게 노출하지 않습니다.
                // 필요 시 에러 코드에 따라 추가 분기 처리만 합니다.
                if let authError = error as NSError?, authError.domain == AuthErrorDomain {
                    switch AuthErrorCode(rawValue: authError.code) {
                    case .wrongPassword, .invalidCredential, .userMismatch, .requiresRecentLogin:
                        // 사용자에게는 일반화된 메시지만 노출
                        self.generalError = ""
                    default:
                        self.generalError = ""
                    }
                } else {
                    self.generalError = ""
                }
                return
            }

            // 재인증 성공 => 비밀번호 변경
            user.updatePassword(to: self.newPassword) { error in
                self.isLoading = false
                if let error = error {
                    // 내부 에러 메시지는 숨기고 일반화된 메시지만 노출
                    if let authError = error as NSError?, authError.domain == AuthErrorDomain,
                       let code = AuthErrorCode(rawValue: authError.code) {
                        switch code {
                        case .weakPassword:
                            self.newPasswordError = "비밀번호가 너무 약합니다. 더 복잡한 비밀번호를 사용해주세요."
                            self.generalError = "비밀번호 변경에 실패했습니다."
                        case .requiresRecentLogin:
                            self.generalError = "보안을 위해 다시 로그인한 후 비밀번호를 변경해주세요."
                        default:
                            self.generalError = "비밀번호 변경에 실패했습니다. 잠시 후 다시 시도해주세요."
                        }
                    } else {
                        self.generalError = "비밀번호 변경에 실패했습니다. 잠시 후 다시 시도해주세요."
                    }
                } else {
                    self.showSuccessAlert = true
                }
            }
        }
    }
}
