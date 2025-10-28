<div align="center">

<img width="480" height="480" alt="TodaysPlayerIcon" src="https://github.com/user-attachments/assets/e8739d9b-a98d-48f9-983f-c4038307bdda" />

🧭 **TodaysPlayer**

로컬 스포츠 매칭을 위한 올인원 플랫폼

![iOS](https://img.shields.io/badge/iOS-26.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-26.0+-green.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

</div>

⸻

## 📑 목차 (Table of Contents)

- [소개](#-소개)
- [핵심 기능](#-핵심-기능)
- [기술 스택](#️-기술-스택)
- [아키텍처](#-아키텍처)
- [프로젝트 구조](#-프로젝트-구조)
- [QA / 트러블슈팅](#-qa--트러블슈팅)
- [로드맵](#-로드맵)
- [개발팀](#-개발팀)
- [라이선스](#️-라이선스)

⸻

## 🧩 소개

**TodaysPlayer**는 스포츠 매칭이 필요한 사용자를 위해 일정 관리와 용병 모집을 편리하게 제공하는 iOS 앱입니다.

- **문제**: 카카오톡, 밴드 등에 흩어진 모집과 모호한 현황 관리
- **해결**: 매치 생성/신청/관리 기능과 원클릭 알림/길찾기 제공
- **가치**: 스포츠 커뮤니티 운영 자동화



⸻

## ⚡ 핵심 기능

### 🏠 홈 대시보드
- ✅ **다음 경기 카드**: 예정된 경기 정보와 D-Day 표시
- ✅ **내 주변 매치**: 근처 풋살/축구 매치 실시간 목록
- ✅ **오늘의 날씨**: WeatherKit 기반 날씨 정보

### ⚽ 매치 관리 시스템
- ✅ **매치 생성**: 일정, 장소, 모집 인원 등록
- ✅ **실시간 모집 현황**: 참가 신청 현황 실시간 확인
- ✅ **참가자 관리**: 승인/거부와 프로필 조회
- ✅ **캘린더 연동**: 경기 일정 확인

### 📝 매치 신청 프로세스
- ✅ **필터링**: 위치, 날짜, 성별, 실력 수준 필터
- ✅ **신청 정보 입력**: 포지션, 실력 수준, 소개 입력

### 👤 개인 통계 및 관리
- ✅ **프로필 관리**: 사용자 정보 수정 및 통계 조회
- ✅ **내 매치 목록**: 신청/참여/개설한 매치 관리
- ✅ **신뢰도 시스템**: 매너 평가와 참여율 기반 신뢰도 점수

⸻

## 🛠️ 기술 스택

- **Language**: Swift 5.9
- **Backend**: Firebase (Firestore, Authentication)
- **Location**: CoreLocation
- **Weather**: WeatherKit
- **Architecture**: MVVM (Model-View-ViewModel)
- **Tooling**: Swift Package Manager

⸻

## 🧱 아키텍처

```
TodaysPlayer
├── App
│   ├── TodaysPlayerApp.swift (Entry Point)
│   ├── AppDelegate (Firebase Setup)
│   └── RootView (Navigation)
├── Scene
│   ├── Home (홈 화면)
│   ├── Apply (매치 신청)
│   ├── MatchList (내 매치 목록)
│   ├── MyPage (프로필)
│   └── Login (인증)
├── Models (Domain Models)
│   ├── User, Match, Apply, Review 등
│   └── Data Models
├── ViewModels (Business Logic)
│   └── 각 Scene별 ViewModel
├── Services
│   ├── FirestoreManager
│   ├── AuthManager
│   ├── UserSessionManager
│   └── LocationManager
└── Extensions & Utilities
```

### 아키텍처 특징
- **MVVM**: UI와 비즈니스 로직 분리
- **Observable**: Swift 5.0의 Observable 프레임워크 사용
- **async/await**: 비동기 처리
- **Firebase**: 실시간 동기화
- **Reusable Components**: 재사용 가능한 UI 컴포넌트

⸻

## 🗂 프로젝트 구조

```
TodaysPlayer/
├── TodaysPlayer/
│   ├── Scene/
│   │   ├── Home/ (HomeView, ViewModels, SubViews)
│   │   ├── Apply/ (ApplyView, ViewModels, SubViews)
│   │   ├── MatchList/ (MatchListView, ViewModels)
│   │   ├── MyPage/ (MyPageView, ViewModels)
│   │   └── Login/ (LoginView)
│   ├── Models/ (User, Match, Apply, Review 등)
│   ├── Services/ (Firestore, Auth, Location)
│   ├── Extensions/ (Date, String, View)
│   ├── ViewModifier/
│   └── Utils/
├── GoogleService-Info.plist
├── Assets.xcassets
└── Info.plist
```

⸻

## 🛎 QA / 트러블슈팅

이슈 관리 및 버그 추적은 [JIRA](https://todaysplayer.atlassian.net/jira/software/projects/TP/boards/2)를 통해 관리하고 있습니다.

> 자세한 버그 리포트 및 이슈는 [JIRA 이슈 트래커](https://todaysplayer.atlassian.net/jira/software/projects/TP/boards/2)를 이용해주세요.

⸻

## 🗺 로드맵

### v1.0 (현재)
- ✅ 사용자 인증 (Firebase Auth)
- ✅ 매치 생성/신청 기능
- ✅ 홈 대시보드 (다음 경기, 날씨, 주변 매치)
- ✅ 내 매치 관리
- ✅ 날씨 연동 (WeatherKit)

### v1.1 (계획 중)
- 🔄 성능 최적화
- 🔄 푸시 알림 추가
- 🔄 SNS 로그인 추가
- 🔄 경기 취소 및 수정기능 추가

### v2.0 (향후)
- 🔜 다국어 지원

⸻

## 👥 개발팀

<table>
  <tr>
    <td align="center"><b>권소정</b></td>
    <td align="center"><b>박정수</b></td>
    <td align="center"><b>이정명</b></td>
    <td align="center"><b>임종혁</b></td>
    <td align="center"><b>최용헌</b></td>
  </tr>
</table>

---

<div align="center">

**⭐ 이 프로젝트가 도움이 되었다면 스타를 눌러주세요! ⭐**

Made with ❤️ by EstCamp Team

</div>

⸻

## 📜 라이선스

이 프로젝트는 **MIT License**를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

```text
MIT License

Copyright (c) 2025 TodaysPlayer Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```
