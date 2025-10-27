//
//  LaunchScreenView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/27/25.
//

import SwiftUI
import Lottie

// MARK: - SwiftUI용 LottieView 래퍼
struct LottieView: UIViewRepresentable {
    let name: String
    let bundle: Bundle
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name, bundle: bundle)
        view.loopMode = loopMode
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // 업데이트 시 재생 유지
        if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }
}

// MARK: - LaunchScreenView
struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.primaryBaseGreen.opacity(0.8), .primaryLight],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            LottieView(name: "BouncingSoccerBall", bundle: .main)
                .scaleEffect(0.6)
                .frame(width: 100, height: 100)

//            VStack {
//                Spacer()
//                Text("Today's Player")
//                    .font(.title.bold())
//                    .foregroundColor(.white)
//                    .padding(.bottom, 80)
//            }
        }
    }
}
