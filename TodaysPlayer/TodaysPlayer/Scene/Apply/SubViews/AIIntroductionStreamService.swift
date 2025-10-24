//
//  AIIntroductionStreamService.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/23/25.
//

import Foundation

class AIIntroductionStreamService {
    // MARK: - properties
    private let clientID: String
    private let apiURLPrefix = "https://kdt-api-function.azurewebsites.net/api/v1/"
    
    private var currentTask: URLSessionTask?
    
    // MARK: - initialization
    init(clientID: String) {
        self.clientID = clientID
    }
    
    // MARK: - public methods
    
    func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    // sse 스트리밍 방식으로 자기소개 생성
    // parameters: postion/skillLevel/streamHandler
    func generateIntroductionStream(
        position: String?,
        skillLevel: String?,
        streamHandler: @escaping (String) -> Void
    ) async throws {
        let prompt = buildPrompt(position: position, skillLevel: skillLevel)
        
        guard let queryEncoded = prompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw AIIntroductionError.invalidRequest
        }
        
        let apiUrlString = apiURLPrefix + "question/sse-streaming?client_id=\(clientID)&content=\(queryEncoded)"
        
        guard let apiUrl = URL(string: apiUrlString) else {
            throw AIIntroductionError.invalidRequest
        }
        
        try await withTaskCancellationHandler {
            let (asyncBytes, response) = try await URLSession.shared.bytes(from: apiUrl)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw AIIntroductionError.invalidRequest
            }
            
            var accumulatedText = ""
            
            for try await line in asyncBytes.lines {
                try Task.checkCancellation()
                // "data:" 로 시작하는 라인만 처리
                print(line)
                try? await Task.sleep(for: .seconds(0.03))
                if line.hasPrefix("data:") {
                    // "data: " 제거 (6글자)
                    let jsonString = String(line.dropFirst(6))
                    
                    if let content = parseSSEContent(jsonString) {
                        accumulatedText += content
                        // 실시간으로 누적된 텍스트 전달
                        streamHandler(accumulatedText)
                    }
                }
            }
        } onCancel: {
            print("AI 스트리밍이 취소되었습니다")
        }
    }
    
    private func parseSSEContent(_ jsonString: String) -> String? {
        let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        
        let jsonFormatted = trimmed.replacingOccurrences(of: "'", with: "\"")
        
        guard let data = jsonFormatted.data(using: .utf8) else {
            return nil
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let type = json["type"] as? String,
               type == "continue",
               let dataDict = json["data"] as? [String: Any],
               let content = dataDict["content"] as? String {
                return content
            }
        } catch {
            return nil
        }
        
        return nil
    }
        
        private func buildPrompt(position: String?, skillLevel: String?) -> String {
            var prompt = """
            당신은 풋살/축구 매칭 앱의 용병 신청 자기소개를 작성하는 AI입니다.
            
            사용자 정보:
            """
            
            // 포지션 정보 추가
            if let position = position, !position.isEmpty {
                prompt += "\n- 포지션: \(position)"
            } else {
                prompt += "\n- 포지션: 미정 (자유 포지션)"
            }
            
            // 실력 수준 정보 추가
            if let skillLevel = skillLevel, !skillLevel.isEmpty {
                let koreanLevel = skillLevel.skillLevelToKorean()
                prompt += "\n- 실력 수준: \(koreanLevel)"
            } else {
                prompt += "\n- 실력 수준: 보통"
            }
            
            prompt += """
            
            
            다음 조건에 맞춰 자기소개를 작성해주세요:
            1. 3줄 이내로 간결하게
            2. 친근하고 열정적인 톤
            3. 플레이 스타일이나 강점 포함
            4. 경기 참여 각오 포함
            5. 인사말로 시작 (예: "안녕하세요!")
            6. 출력 결과에서 마크다운 삭제
            
            예시:
            "안녕하세요! 축구 경력 3년차로 수비를 담당하고 있습니다. 패스워크를 중시하며 팀워크를 중요하게 생각합니다. 좋은 경기 만들어가요!"
            
            위 조건에 맞춰 자기소개만 작성해주세요. 다른 설명은 불필요합니다.
            """
            
            return prompt
        }
    }
