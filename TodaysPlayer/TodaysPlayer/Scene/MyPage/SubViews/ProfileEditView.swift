//  ProfileEditView.swift
//  TodaysPlayer
//
//  Created by J on 9/29/25.
//

import SwiftUI
import PhotosUI

/// 프로필 편집 화면
/// - AppStorage에 저장된 사용자 프로필 정보를 읽어와 화면에서 편집하고, 저장 버튼으로 다시 반영합니다.
/// - 사진은 PhotosPicker를 통해 선택하며, 선택한 이미지는 `Data`로 임시 보관 후 저장 시 반영됩니다.
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    // ViewModel 주입: 외부에서 주입하거나 기본 생성자를 사용합니다.
    @StateObject var viewModel: ProfileEditViewModel = .init()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 프로필 사진
                VStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if let data = viewModel.editAvatarData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundStyle(Color(.green))
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .background(Circle().fill(Color(.systemGray6)))
                        // 프로필 사진 선택 버튼 (이미지 선택 시 selectedPhotoItem이 업데이트됨)
                        PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                            ZStack {
                                Circle().fill(Color(.white)).frame(width: 32, height: 32)
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                    }
                    Text("프로필 사진을 변경하려면 카메라 아이콘을 클릭하세요.")
                            .font(.caption)
                            .foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.white)))
                
                // 기본 정보
                VStack(alignment: .leading, spacing: 16) {
                    Text("기본 정보")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("닉네임").font(.caption).foregroundColor(.gray)
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.black)
                            Text(UserSessionManager.shared.currentUser?.displayName ?? "")
                                .foregroundColor(.black)
                                .font(.body)
                                .disabled(true)
                            Spacer()
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("연락처").font(.caption).foregroundColor(.gray)
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.black)
                            Text(UserSessionManager.shared.currentUser?.phoneNumber ?? "")
                                .foregroundColor(.black)
                                .font(.body)
                                .disabled(true)
                            Spacer()
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("이메일").font(.caption).foregroundColor(.gray)
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.black)
                            Text(UserSessionManager.shared.currentUser?.email ?? "")
                                .foregroundColor(.black)
                                .font(.body)
                                .disabled(true)
                            Spacer()
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                    }
                    
                    let regionBinding = Binding(
                        get: {viewModel.region },
                        set: {viewModel.region = $0 }
                    )
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("거주 지역").font(.caption).foregroundColor(.gray)
                            Menu {
                                Picker("거주 지역", selection: regionBinding) {
                                   ForEach(ProfileEditViewModel.Region.allCases, id: \.self) { r in
                                       Text(r.rawValue).tag(r)
                                    }
                                }
                            } label: {
                                HStack(spacing: 35) {
                                    Text(viewModel.region.rawValue)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 20, weight: .regular))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity , alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("성별").font(.caption).foregroundColor(.gray)
                            HStack {
                                Image(systemName: "faceid")
                                    .foregroundColor(.black)
                                Text(UserSessionManager.shared.currentUser?.gender ?? "")
                                    .foregroundColor(.black)
                                    .font(.body)
                                    .disabled(true)
                                Spacer()
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.white)))
            
            let positionBinding = Binding(
                get: {viewModel.position },
                set: {viewModel.position = $0 }
            )
            
            let levelBinding = Binding(
                get: {viewModel.level },
                set: {viewModel.level = $0 }
            )
            
            
            
            // 축구/풋살 정보
            VStack(alignment: .leading, spacing: 16) {
                Text("축구/풋살 정보")
                    .font(.headline)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("주 포지션").font(.caption).foregroundColor(.gray)
                        Menu {
                            Picker("주 포지션", selection: positionBinding) {
                                ForEach(ProfileEditViewModel.Position.allCases, id: \.self) { pos in
                                    Text(pos.rawValue).tag(pos)
                                }
                            }
                        } label: {
                            HStack(spacing: 30) {
                                Text(viewModel.position.rawValue)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 15, weight: .regular))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity , alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 7) {
                        Text("실력 레벨").font(.caption).foregroundColor(.gray)
                        Menu {
                            Picker("실력 레벨", selection: levelBinding) {
                                ForEach(ProfileEditViewModel.SkillLevel.allCases, id: \.self) { lv in
                                  Text(lv.rawValue).tag(lv)
                                }
                            }
                        } label: {
                            HStack(spacing: 35) {
                                Text(viewModel.level.rawValue)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 15, weight: .regular))
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 8  ).fill(Color(.systemGray5)))
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("선호 시간대").font(.caption).foregroundColor(.gray)
                    HStack(spacing: 6) {
                        ForEach(ProfileEditViewModel.TimeOption.allCases, id: \.self) { t in
                            Button(action: {
                                viewModel.togglePreferredTime(t)
                            }) {
                                Text(t.rawValue)
                                    .foregroundColor(viewModel.preferredTimes.contains(t) ? .white : .black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(viewModel.preferredTimes.contains(t) ? Color(.green) : Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("자기소개 (플레이 스타일 / 축구 경력 / 각오 등)")
                        .font(.caption).foregroundColor(.gray)
                    TextEditor(text: $viewModel.editIntro)
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(4)
                        .frame(minHeight: 120)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.white)))
            HStack {
                Spacer()
                Button(action: {
                    // 입력값을 저장하고 화면을 닫습니다.
                    viewModel.save()
                    dismiss()
                })
                {
                    Text("저장")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.5)))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .toolbar(.hidden, for: .tabBar)
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
        .navigationTitle("프로필 편집")
        .navigationBarTitleDisplayMode(.large)

        // 화면 최초 진입 시, 저장된 값을 편집용 상태로 로드 (한 번만 실행)
        .onAppear {
            viewModel.loadIfNeeded()
        }
        // 사용자가 사진을 선택할 때마다 호출되어, 선택된 이미지를 Data로 로드
        .onChange(of: viewModel.selectedPhotoItem) { _, _ in
            Task { await viewModel.loadSelectedPhoto() }
        }
    }
}

//#Preview {
//    ProfileEditView(viewModel: .init())
//}

