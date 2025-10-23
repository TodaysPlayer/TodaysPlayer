//
//  PwEditView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/1/25.
//

import SwiftUI
import Observation

struct PwEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PwEditViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 현재 비밀번호
                    VStack(alignment: .leading, spacing: 6) {
                        Text("현재 비밀번호").font(.caption).foregroundColor(.gray)
                        SecureField("현재 비밀번호", text: $viewModel.currentPassword)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: viewModel.currentPassword) { viewModel.validateLocally() }
                        if let error = viewModel.currentPasswordError {
                            Text(error).font(.caption).foregroundColor(.red)
                        }
                    }

                    // 새 비밀번호
                    VStack(alignment: .leading, spacing: 6) {
                        Text("신규 비밀번호").font(.caption).foregroundColor(.gray)
                        SecureField("신규 비밀번호", text: $viewModel.newPassword)
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: viewModel.newPassword) { viewModel.validateLocally() }
                        if let error = viewModel.newPasswordError {
                            Text(error).font(.caption).foregroundColor(.red)
                        }
                    }

                    // 새 비밀번호 확인
                    VStack(alignment: .leading, spacing: 6) {
                        Text("신규 비밀번호 재입력").font(.caption).foregroundColor(.gray)
                        SecureField("신규 비밀번호 재입력", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: viewModel.confirmPassword) { viewModel.validateLocally() }
                        if let error = viewModel.confirmPasswordError {
                            Text(error).font(.caption).foregroundColor(.red)
                        }
                    }

                    if let general = viewModel.generalError {
                        Text(general).font(.caption).foregroundColor(.red)
                    }

                    Button(action: {
                        viewModel.changePassword()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            }
                            Text("비밀번호 변경")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background((viewModel.isFormValid && !viewModel.isLoading) ? Color.green : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(40)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
                .padding(16)
            }
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
            .toolbar(.hidden, for: .tabBar)
            .navigationTitle("비밀번호 변경")
            .alert("비밀번호가 변경되었습니다", isPresented: $viewModel.showSuccessAlert) {
                Button("확인") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    PwEditView()
}
