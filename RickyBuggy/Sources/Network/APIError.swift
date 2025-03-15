//
//  APIError.swift
//  RickyBuggy
//

import Foundation

enum APIError: Error, Hashable {
    case imageDataRequestFailed(Error?)
    case charactersRequestFailed(Error?)
    case characterDetailRequestFailed(Error?)
    case locationRequestFailed(Error?)
    
    // MARK: - Equatable
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.imageDataRequestFailed, .imageDataRequestFailed),
             (.charactersRequestFailed, .charactersRequestFailed),
             (.characterDetailRequestFailed, .characterDetailRequestFailed),
             (.locationRequestFailed, .locationRequestFailed):
            return true
        default:
            return false
        }
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .imageDataRequestFailed:
            hasher.combine("imageDataRequestFailed")
        case .charactersRequestFailed:
            hasher.combine("charactersRequestFailed")
        case .characterDetailRequestFailed:
            hasher.combine("characterDetailRequestFailed")
        case .locationRequestFailed:
            hasher.combine("locationRequestFailed")
        }
    }
}


extension APIError: LocalizedError {
    var errorDescription: String? {
        let baseMessage: String
        let underlyingMessage: String?

        switch self {
        case .imageDataRequestFailed(let error):
            baseMessage = "Could not download image"
            underlyingMessage = error?.localizedDescription
        case .charactersRequestFailed(let error):
            baseMessage = "Could not fetch characters"
            underlyingMessage = error?.localizedDescription
        case .characterDetailRequestFailed(let error):
            baseMessage = "Could not get details of character"
            underlyingMessage = error?.localizedDescription
        case .locationRequestFailed(let error):
            baseMessage = "Could not get details of location"
            underlyingMessage = error?.localizedDescription
        }

        // If there's an underlying error, append its message
        if let underlyingMessage {
            return "\(baseMessage). Underlying error: \(underlyingMessage)"
        } else {
            return baseMessage
        }
    }
}
