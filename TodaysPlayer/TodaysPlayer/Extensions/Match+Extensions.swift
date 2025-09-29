import Foundation
import SwiftUI

extension Match {
    /// 매치에 대한 태그 생성
    /// - Returns: 가격, 실력 레벨, 마감 임박 등에 따른 태그 배열
    func createMatchTags() -> [MatchTag] {
        var tags: [MatchTag] = []
        
        // 가격 태그
        if self.price == 0 {
            tags.append(MatchTag(text: "무료", color: .green, icon: "gift.fill"))
        } else if self.price <= 5000 {
            tags.append(MatchTag(text: "저렴", color: .blue, icon: "wonsign.circle.fill"))
        }
        
        // 실력 레벨 태그
        if self.skillLevel == "beginner" {
            tags.append(MatchTag(text: "초보환영", color: .blue, icon: "person.fill"))
        }
        
        // 마감 임박 태그 (임시)
        if Int.random(in: 1...10) <= 3 {
            tags.append(MatchTag(text: "마감임박", color: .orange, icon: "bolt.fill"))
        }
        
        return tags
    }
}
