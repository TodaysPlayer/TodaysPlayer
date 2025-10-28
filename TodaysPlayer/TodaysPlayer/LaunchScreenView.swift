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
        VStack {
            Spacer().frame(height: 60) // 텍스트 위 여백

            Text("오늘의 용병")
                .font(.title.bold())
                .foregroundColor(.black)

            Spacer() // 텍스트와 애니메이션 사이 공간

            LottieView(name: "BouncingSoccerBall", bundle: .main)
                .scaleEffect(0.6)
                .frame(width: 150, height: 150)

            Spacer() // 애니메이션 아래 공간
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
