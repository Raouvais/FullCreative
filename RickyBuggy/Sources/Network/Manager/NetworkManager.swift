//
//  NetworkManager.swift
//  RickyBuggy
//

import Foundation
import Combine

final class NetworkManager: NetworkManagerProtocol {
    
    static let RANDOM_HOST_NAME_TO_FAIL_REQUEST = "thisshouldfail.com"
    
    func publisher(path: String, method: String = "GET", body: Data? = nil, timeout: TimeInterval = 5) -> AnyPublisher<Data, Error> {
        var components = URLComponents()
        components.scheme = "https"
        
        // Maintain random failure functionality
        components.host = Int.random(in: 1...10) > 3 ? "rickandmortyapi.com" : NetworkManager.RANDOM_HOST_NAME_TO_FAIL_REQUEST
        components.path = path
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method
        request.httpBody = body

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func publisher(fromURLString urlString: String) -> AnyPublisher<Data, Error> {
        Just(urlString)
            .compactMap(URL.init)
            .setFailureType(to: Error.self)
            .flatMap { url in
                URLSession.shared.dataTaskPublisher(for: url)
                    .map(\.data)
                    .mapError { $0 as Error }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
