//
//  ApplyView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

// 지역 enum 정의
enum Region: String, CaseIterable {
    case seoul = "서울"
    case gyeonggi = "경기"
    case incheon = "인천"
    case kangwon = "강원"
    case daejeonSejong = "대전/세종"
    case chungbuk = "충북"
    case chungnam = "충남"
    case daegu = "대구"
}

// 경기 종류 enum
enum GameType: String, CaseIterable {
    case soccer = "축구"
    case futsal = "풋살"
}

// 실력 레벨 enum
enum SkillLevel: String, CaseIterable {
    case s = "S"
    case a = "A"
    case bPlus = "B+"
    case b = "B"
    case bMinus = "B-"
    case cPlus = "C+"
    case c = "C"
    case cMinus = "C-"
    case d = "D"
    
    var description: String {
        switch self {
        case .s: return "선출(대학&프로출신)"
        case .a: return "선출(중고등부 출신)"
        case .bPlus: return "기본기 중, 팀플레이 상"
        case .b: return "기본기 중, 팀플레이 중"
        case .bMinus: return "기본기 중, 팀플레이 하"
        case .cPlus: return "기본기 하, 팀플레이 상"
        case .c: return "기본기 하, 팀플레이 중"
        case .cMinus: return "기본기 하, 팀플레이 하"
        case .d: return "입문자 레벨"
        }
    }
}

// 성별 enum
enum Gender: String, CaseIterable {
    case male = "남자만"
    case female = "여자만"
    case mixed = "성별무관"
}

// 참가비 enum
enum FeeType: String, CaseIterable {
    case free = "무료"
    case paid = "유료"
}

// 필터 데이터 구조체
struct GameFilter {
    var gameTypes: Set<GameType> = []
    var skillLevels: Set<SkillLevel> = []
    var gender: Gender? = nil
    var feeType: FeeType? = nil
    
    // 서버로 보낼 딕셔너리 형태로 변환
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if !gameTypes.isEmpty {
            dict["gameTypes"] = gameTypes.map { $0.rawValue }
        }
        
        if !skillLevels.isEmpty {
            dict["skillLevels"] = skillLevels.map { $0.rawValue }
        }
        
        if let gender = gender {
            dict["gender"] = gender.rawValue
        }
        
        if let feeType = feeType {
            dict["feeType"] = feeType.rawValue
        }
        
        return dict
    }
    
    // 필터가 비어있는지 확인
    var isEmpty: Bool {
        return gameTypes.isEmpty && skillLevels.isEmpty && gender == nil && feeType == nil
    }
}

struct ApplyView: View {
    @State private var selectedRegion: Region = .incheon
    @State private var isRegionSheetPresented: Bool = false
    @State private var isFilterSheetPresented: Bool = false
    @State private var isScrolling: Bool = false
    
    // 필터 관련 상태
    @State private var currentFilter = GameFilter()
    @State private var tempFilter = GameFilter() // 바텀시트에서 임시로 사용할 필터
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    // 서브타이틀
                    Text("함께할 팀원을 찾아보세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    
                    // 스크랩, 필터, 지역 버튼 (통일된 스타일)
                    HStack(spacing: 12) {
                        // 스크랩 버튼
                        Button(action: {
                            print("스크랩 버튼 클릭됨")
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Text("스크랩")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }
                        
                        // 필터 버튼
                        Button(action: {
                            tempFilter = currentFilter // 현재 필터를 임시 필터에 복사
                            isFilterSheetPresented = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: currentFilter.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Text("필터")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }
                        
                        // 지역 선택 버튼 (새로운 스타일)
                        Button(action: {
                            isRegionSheetPresented = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "location")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Text(selectedRegion.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    // 게시글 공고 스크롤뷰
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // 스크롤 감지를 위한 투명한 뷰
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 1)
                                .id("top")
                                .onAppear {
                                    isScrolling = false
                                }
                                .onDisappear {
                                    isScrolling = true
                                }
                            
                            // 샘플 게시글들
                            ForEach(1...20, id: \.self) { index in
                                PostCardView(title: "게시글 \(index)", content: "내용 \(index)")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100) // 플로팅 버튼을 위한 여백
                    }
                }
                
                // 플로팅 액션 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingActionButton
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 34) // Safe Area 고려
            }
            .navigationTitle("용병 모집")
        }
        .sheet(isPresented: $isRegionSheetPresented) {
            regionBottomSheet
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            filterBottomSheet
        }
    }
    
    // 플로팅 액션 버튼
    private var floatingActionButton: some View {
        Button(action: {
            // 글쓰기 화면으로 이동하는 액션
            print("글쓰기 버튼 탭됨")
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                
                if !isScrolling {
                    Text("글쓰기")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, isScrolling ? 16 : 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: isScrolling ? 28 : 25)
                    .fill(Color.green)
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isScrolling)
    }
    
    // 지역 선택 바텀시트
    private var regionBottomSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // 바텀시트 헤더
                HStack {
                    Text("지역")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("완료") {
                        isRegionSheetPresented = false
                    }
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // 지역 목록
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Region.allCases, id: \.self) { region in
                            regionRow(region)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .presentationDetents([.height(225)])
            .presentationDragIndicator(.visible)
        }
    }
    
    // 지역 선택 행
    private func regionRow(_ region: Region) -> some View {
        Button(action: {
            selectedRegion = region
            isRegionSheetPresented = false
        }) {
            HStack {
                Text(region.rawValue)
                    .foregroundColor(.primary)
                    .font(.body)
                
                Spacer()
                
                if selectedRegion == region {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 필터 선택 바텀시트
    private var filterBottomSheet: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text("필터")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    isFilterSheetPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
                .padding(.horizontal, 20)
            
            // 필터 옵션들
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 경기 종류 섹션
                    filterSection(title: "경기 종류") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                filterToggleButton(
                                    title: gameType.rawValue,
                                    isSelected: tempFilter.gameTypes.contains(gameType)
                                ) {
                                    if tempFilter.gameTypes.contains(gameType) {
                                        tempFilter.gameTypes.remove(gameType)
                                    } else {
                                        tempFilter.gameTypes.insert(gameType)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 실력 레벨 섹션
                    filterSection(title: "실력") {
                        LazyVGrid(columns: [
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(SkillLevel.allCases, id: \.self) { level in
                                filterToggleButton(
                                    title: "\(level.rawValue): \(level.description)",
                                    isSelected: tempFilter.skillLevels.contains(level)
                                ) {
                                    if tempFilter.skillLevels.contains(level) {
                                        tempFilter.skillLevels.remove(level)
                                    } else {
                                        tempFilter.skillLevels.insert(level)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 성별 섹션
                    filterSection(title: "성별") {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                filterToggleButton(
                                    title: gender.rawValue,
                                    isSelected: tempFilter.gender == gender
                                ) {
                                    tempFilter.gender = (tempFilter.gender == gender) ? nil : gender
                                }
                            }
                        }
                    }
                    
                    // 참가비 섹션
                    filterSection(title: "참가비") {
                        HStack(spacing: 10) {
                            ForEach(FeeType.allCases, id: \.self) { feeType in
                                filterToggleButton(
                                    title: feeType.rawValue,
                                    isSelected: tempFilter.feeType == feeType
                                ) {
                                    tempFilter.feeType = (tempFilter.feeType == feeType) ? nil : feeType
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100) // 하단 버튼 공간 확보
            }
            
            // 하단 버튼들
            VStack(spacing: 12) {
                Divider()
                
                HStack(spacing: 12) {
                    // 조건 초기화 버튼
                    Button(action: {
                        tempFilter = GameFilter()
                    }) {
                        Text("조건 초기화")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    
                    // 적용하기 버튼
                    Button(action: {
                        currentFilter = tempFilter
                        isFilterSheetPresented = false
                        
                        // 필터 적용 로직
                        let filterDict = currentFilter.toDictionary()
                        print("적용된 필터:", filterDict)
                        
                        // 여기서 서버에 필터 조건을 보내고 결과를 받아올 수 있습니다
                    }) {
                        Text("적용하기")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
    
    // 필터 섹션 헬퍼 함수
    private func filterSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content()
        }
    }
    
    // 필터 토글 버튼 헬퍼 함수
    private func filterToggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

// 샘플 게시글 카드 뷰
struct PostCardView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        ApplyView()
    }
}
