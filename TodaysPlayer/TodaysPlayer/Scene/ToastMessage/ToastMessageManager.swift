//
//  ToastMessageManager.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/2/25.
//

import SwiftUI

@Observable
final class ToastMessageManager {
    var isShowing: Bool = false
    var type: ToastMessageType? = nil
    
    private var hideTask: Task<Void, Never>?
    
    func show(_ type: ToastMessageType, duration: TimeInterval = 2.0) {
        hideTask?.cancel()
        self.type = type
        
        withAnimation { isShowing = true }
        
        hideTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            withAnimation { isShowing = false }
        }
        
    }
}
