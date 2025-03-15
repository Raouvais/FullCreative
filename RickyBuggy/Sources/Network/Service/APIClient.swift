//
//  APIService.swift
//  RickyBuggy
//

import Foundation
import Combine

final class APIClient: APIProtocol {
    private let networkManager: NetworkManagerProtocol?
    
    init() {
        self.networkManager = DIContainer.shared.resolve(NetworkManager.self)
    }
    
    func imageDataPublisher(fromURLString urlString: String) -> ImageDataPublisher {
        guard let networkManager = networkManager else { return Empty().eraseToAnyPublisher() }
        
        return Just(urlString)
            .setFailureType(to: Error.self)
            .flatMap { networkManager.publisher(fromURLString: $0) }
            .mapError { error in
                debugPrint("Image data request failed: \(error)")
                return APIError.imageDataRequestFailed(error)
            }
            .eraseToAnyPublisher()
    }
    
    func charactersPublisher() -> CharactersPublisher {
        guard let networkManager = networkManager else { return Empty().eraseToAnyPublisher() }

        return Just("/api/character/[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]")
            .setFailureType(to: Error.self)
            .flatMap { path in
                networkManager.publisher(path: path, method: "GET", body: nil, timeout: 5)
            }
            .decode(type: [CharacterResponseModel].self, decoder: JSONDecoder())
            .mapError { error in
                debugPrint("Characters request failed: \(error)")
                return APIError.charactersRequestFailed(error)
            }
            .eraseToAnyPublisher()
    }
    
    func characterDetailPublisher(with id: String) -> CharacterDetailsPublisher {
        guard let networkManager = networkManager else { return Empty().eraseToAnyPublisher() }

        return Just("/api/character/\(id)")
            .setFailureType(to: Error.self)
            .flatMap { path in
                networkManager.publisher(path: path, method: "GET", body: nil, timeout: 5)
            }
            .decode(type: CharacterResponseModel.self, decoder: JSONDecoder())
            .mapError { error in
                debugPrint("Character detail request failed: \(error)")
                return APIError.characterDetailRequestFailed(error)
            }
            .eraseToAnyPublisher()
    }
    
    func locationPublisher(with id: String) -> LocationPublisher {
        guard let networkManager = networkManager else { return Empty().eraseToAnyPublisher() }

        return Just("/api/location/\(id)")
            .setFailureType(to: Error.self)
            .flatMap { path in
                networkManager.publisher(path: path, method: "GET", body: nil, timeout: 5)
            }
            .decode(type: LocationDetailsResponseModel.self, decoder: JSONDecoder())
            .mapError { error in
                debugPrint("Location request failed: \(error)")
                return APIError.locationRequestFailed(error)
            }
            .eraseToAnyPublisher()
    }
}
