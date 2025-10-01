//
//  FAQItem.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/1/25.
//

import Foundation

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

extension FAQItem {
    static let faqs: [FAQItem] = [
        FAQItem(
            question: "용병 신청은 어떻게 하나요?",
            answer: "용병 모집 페이지에서 원하는 경기를 선택하고 '신청하기' 버튼을 클릭하면 됩니다. 주최자가 승인하면 경기 참여가 확정됩니다."
        ),
        FAQItem(
            question: "경기 참여비는 언제 결제하나요?",
            answer: "경기 당일 현장에서 주최자에게 직접 결제하시면 됩니다. 일부 경기는 사전 결제가 필요할 수 있으니 경기 상세 정보를 확인해주세요."
        ),
        FAQItem(
            question: "경기 취소는 언제까지 가능한가요?",
            answer: "경기 시작 2시간 전까지 취소 가능합니다. 그 이후 취소 시에는 패널티가 부과될 수 있습니다."
        ),
        FAQItem(
            question: "평점은 어떻게 매겨지나요?",
            answer: "경기 종료 후 함께 플레이한 다른 참가자들이 매너, 실력, 협력도 등을 종합적으로 평가하여 1~5점으로 평점을 매깁니다."
        )
    ]
}
