//
//  CharacterDetailViewModel.swift
//  RickyBuggy
//

import Combine
import Foundation

final class CharacterDetailViewModel: ObservableObject {
    @Published var showsLocationDetailsView = false

    @Published private(set) var data: (characterDetails: CharacterResponseModel, location: LocationDetailsResponseModel)?
    @Published private(set) var CharacterPhotoData: Data?
    @Published private(set) var characterErrors: [APIError] = []

    @Published private(set) var title: String = "-"
    @Published private(set) var popularityName: String = "-"
    @Published private(set) var url: String = "-"
    @Published private(set) var created: String = "-"
    
    @Published private(set) var details: String = "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."
    
    private let showsLocationDetailsSubject = CurrentValueSubject<Bool?, Never>(nil)

    private let characterIDSubject = CurrentValueSubject<Int?, Never>(nil)
    private let dataSubject = CurrentValueSubject<(characterDetails: CharacterResponseModel, location: LocationDetailsResponseModel)?, Never>(nil)

    private var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    init(characterId: Int, name: String) {
        self.title = name

        guard let apiService = DIContainer.shared.resolve(APIClient.self) else { return }

        showsLocationDetailsSubject
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.showsLocationDetailsView = value
            }
            .store(in: &cancellables)

        let dataPublisher = dataSubject
            .compactMap { $0 }
            .share()

        let characterDetailsPublisher = dataPublisher
            .map(\.characterDetails)
            .receive(on: DispatchQueue.main)

        dataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.characterErrors.append(.characterDetailRequestFailed(error))
                }
            }, receiveValue: { [weak self] characterDetail, location in
                self?.data = (characterDetail, location)
            })
            .store(in: &cancellables)

        characterDetailsPublisher
            .map(\.image)
            .flatMap { [weak self] imageURLString -> ImageDataPublisher in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return apiService.imageDataPublisher(fromURLString: imageURLString)
            }
            .replaceError(with: Data())
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.CharacterPhotoData = data
            }
            .store(in: &cancellables)

        characterDetailsPublisher
            .map(\.name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)

        characterDetailsPublisher
            .map(\.episode)
            .map(\.count)
            .compactMap(AppearanceFrequency.init(count:))
            .map(\.popularity)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] popularity in
                self?.popularityName = popularity
            }
            .store(in: &cancellables)
        
        characterDetailsPublisher
            .map(\.url)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] popularity in
                self?.popularityName = popularity
            }
            .store(in: &cancellables)

        characterDetailsPublisher
            .map(\.created)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] created in
                self?.created = created
            }
            .store(in: &cancellables)

        characterIDSubject.send(characterId)
    }
    
    // MARK: - Inputs

    func setShowsLocationDetails() {
        showsLocationDetailsSubject.send(true)
    }
    
    func requestData() {
        guard isLoading == false else { return }

        data = nil
        characterErrors.removeAll()
        isLoading = true

        if let apiService = DIContainer.shared.resolve(APIClient.self), let characterID = characterIDSubject.value {
            Publishers.Zip(apiService.characterDetailPublisher(with: String(characterID)),
                           apiService.locationPublisher(with: "\(data?.location.id ?? 2)"))
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.characterErrors.append(.characterDetailRequestFailed(error))
                    }
                    self?.isLoading = false
                }, receiveValue: { [weak self] characterDetail, comments in
                    self?.dataSubject.send((characterDetail, comments))
                })
                .store(in: &cancellables)
        }
    }
}
