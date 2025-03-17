//
//  AppearanceFrequency.swift
//  RickyBuggy
//

import Foundation


/// Level selected based on number of appearances in the show
enum AppearanceFrequency {
    case high, medium, low

    init(count: Int) {
        switch count {
        case 10...:
            self = .high
        case 3...9:
            self = .medium
        default:
            self = .low
        }
    }
    
    var popularity: String {
        switch self {
        case .high:
            return "So popular!"
        case .medium:
            return "Kind of popular"
        case .low:
            return "Meh"
        }
    }
}
