//
//  ToastManager.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/29/25.
//


import UIKit

final class ToastManager {
    static let shared = ToastManager()
    private init() {}

    // Simple fallback implementation that presents a system alert.
    // Matches usage in AccountView: title, message, buttonTitle, completion closure.
    func show(title: String,
              message: String,
              buttonTitle: String = "확인",
              completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first,
                  let rootVC = window.rootViewController else {
                completion?()
                return
            }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
                completion?()
            }))
            rootVC.present(alert, animated: true)
        }
    }
}