//
//  AppMainViewModel.swift
//  RickyBuggy
//

import Combine
import Foundation

final class AppMainViewModel: ObservableObject {
    @Published var showsSortActionSheet: Bool = false
    @Published var sortMethod: SortMethod = .name
    @Published var characters: [CharacterResponseModel] = []
    
    @Published private(set) var characterErrors: [APIError] = []
    @Published private(set) var sortMethodDescription: String = "Choose Sorting"

    private let showsSortActionSheetSubject = CurrentValueSubject<Bool?, Never>(nil)
    private let sortMethodSubject = CurrentValueSubject<SortMethod?, Never>(nil)

    private var isLoading = false
    private var hasFetchedData = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        sortMethodSubject
            .compactMap { $0 }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] sortMethod in
                self?.sortMethod = sortMethod
                self?.sortMethodDescription = sortMethod.description
                self?.applySorting() // ✅ Only sort locally instead of re-fetching
            })
            .store(in: &cancellables)
        
        showsSortActionSheetSubject
            .compactMap { $0 }
            .removeDuplicates()
            .assign(to: \.showsSortActionSheet, on: self)
            .store(in: &cancellables)
    }
    
    /// Fetches data only if it hasn't been fetched already
    func fetchDataIfNeeded() {
        guard !hasFetchedData else { return }
        hasFetchedData = true
        requestData()
    }

    func setSortMethod(_ sortMethod: SortMethod) {
        sortMethodSubject.send(sortMethod)
    }
    
    func setShowsSortActionSheet() {
        showsSortActionSheetSubject.send(false) // Reset state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showsSortActionSheetSubject.send(true) // Re-trigger action sheet
        }
    }
    
    func requestData() {
        #if DEBUG
        debugPrint("Fetching data")
        #endif
        
        characterErrors.removeAll()
        isLoading = true

        let apiService = DIContainer.shared.resolve(APIClient.self)
        
        apiService?.charactersPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.characterErrors.append(error)
                case .finished:
                    break
                }
                
                self?.isLoading = false
            }, receiveValue: { [weak self] characters in
                self?.characters = characters
                self?.applySorting() // ✅ Sort the fetched data
            })
            .store(in: &cancellables)
    }
    
    /// Sorts the characters **without re-fetching**
    private func applySorting() {
        characters = characters.sorted(by: sortMethod)
    }
}
