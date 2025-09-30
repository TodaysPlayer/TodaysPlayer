//
//  LocationManager.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import Foundation
import CoreLocation
import SwiftUI

@Observable
class LocationManager: NSObject {
    private let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isLocationEnabled = false
    var errorMessage: String?
    
    // 위치 정확도 설정
    private let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    
    
    override init() {
        super.init()
        
        setupLocationManager()
    }
    
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        // 위치 권한 요청
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            errorMessage = "위치 권한이 필요합니다. 설정에서 위치 권한을 허용해주세요."
            
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
            
        @unknown default:
            errorMessage = "알 수 없는 위치 권한 상태입니다."
        }
    }
    
    func startLocationUpdates() {
        // 위치 업데이트 시작
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            errorMessage = "위치 권한이 허용되지 않았습니다."
            
            return
        }
        
        // 백그라운드 스레드에서 위치 서비스 상태 확인
        Task {
            let isLocationServicesEnabled = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let enabled = CLLocationManager.locationServicesEnabled()
                    
                    continuation.resume(returning: enabled)
                }
            }
            
            await MainActor.run {
                guard isLocationServicesEnabled else {
                    self.errorMessage = "위치 서비스가 비활성화되어 있습니다."
                    return
                }
                
                self.locationManager.startUpdatingLocation()
                self.isLocationEnabled = true
                self.errorMessage = nil
            }
        }
    }
    
    func stopLocationUpdates() {
        // 위치 업데이트 중지
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    func getCurrentLocation() async -> CLLocation? {
        // 현재 위치 가져오기 (한 번만)
        return await withCheckedContinuation { continuation in
            // 이미 위치가 있고 최근 것이라면 반환
            if let location = currentLocation, location.timestamp.timeIntervalSinceNow > -300 { // 5분 이내
                continuation.resume(returning: location)
                
                return
            }
            
            // 위치 요청
            requestLocationPermission()
            
            // 위치 업데이트를 기다림
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                continuation.resume(returning: self.currentLocation)
            }
        }
    }
    
    var isLocationAvailable: Bool {
        // 사용자 위치가 사용 가능한지 확인
        return currentLocation != nil && authorizationStatus == .authorizedWhenInUse
    }
    
    var permissionStatusText: String {
        // 위치 권한 상태를 한국어로 반환
        switch authorizationStatus {
        case .notDetermined:
            return "위치 권한을 요청하세요"
            
        case .denied, .restricted:
            return "위치 권한이 거부되었습니다"
            
        case .authorizedWhenInUse:
            return "위치 권한이 허용되었습니다"
            
        case .authorizedAlways:
            return "위치 권한이 항상 허용되었습니다"
            
        @unknown default:
            return "알 수 없는 상태"
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        errorMessage = nil
        
        print("위치 업데이트: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
        
        errorMessage = "위치를 가져올 수 없습니다: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
            errorMessage = nil
            
        case .denied, .restricted:
            stopLocationUpdates()
            errorMessage = "위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
            
        case .notDetermined:
            errorMessage = nil
            
        @unknown default:
            errorMessage = "알 수 없는 위치 권한 상태입니다."
        }
    }
}
