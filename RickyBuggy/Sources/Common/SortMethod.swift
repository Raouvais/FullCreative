//
//  SortMethod.swift
//  RickyBuggy
//

// Sorting method for characters based on name or episodes count
enum SortMethod: Int {
    case name
    case episodesCount
}

extension SortMethod: CustomStringConvertible {
    var description: String {
        switch self {
        case .name:
            return "Name"
        case .episodesCount:
            return "Episodes Count"
        }
    }
}

extension Array where Element == CharacterResponseModel {
    func sorted(by method: SortMethod) -> [CharacterResponseModel] {
        switch method {
        case .name:
            return self.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .episodesCount:
            return self.sorted { $0.episode.count > $1.episode.count }
        }
    }
}

