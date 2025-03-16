//
//  CharactersListItemViewModel.swift
//  RickyBuggy
//

import Combine
import Foundation

final class CharactersListItemViewModel: ObservableObject {

    @Published private(set) var characterErrors: [APIError] = []

    @Published private(set) var title: String = "-"
    @Published private(set) var characterImageData: Data?
    @Published private(set) var created: String = "-"
    @Published private(set) var url: String = "-"

    private let characterSubject = CurrentValueSubject<CharacterResponseModel?, Never>(nil)

    private var cancellables = Set<AnyCancellable>()
    
    init(character: CharacterResponseModel) {
        let apiService = DIContainer.shared.resolve(APIClient.self)
        let characterSharedPublisher = characterSubject
            .compactMap { $0 }
            .share()
        
        characterSharedPublisher
            .map(\.name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)
        
        characterSharedPublisher
            .map(\.image)
            .flatMap { [weak self] imageURLString -> ImageDataPublisher in
                guard let self = self, let apiService = apiService else {
                    return Empty().eraseToAnyPublisher()
                }
                return apiService.imageDataPublisher(fromURLString: imageURLString)
            }
            .replaceError(with: Data())
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.characterImageData = data
            }
            .store(in: &cancellables)
        
        characterSharedPublisher
            .map(\.created)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] created in
                self?.created = created
            }
            .store(in: &cancellables)
        
        characterSharedPublisher
            .map(\.url)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.url = url
            }
            .store(in: &cancellables)
        
        characterSubject.send(character)
    }
}
