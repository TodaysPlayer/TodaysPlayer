//
//  MatchLocation.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct MatchLocation: Codable, Equatable, Hashable {
    let name: String
    let address: String
    let coordinates: Coordinates
}
