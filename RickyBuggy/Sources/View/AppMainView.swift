//
//  AppMainView.swift
//  RickyBuggy
//

import SwiftUI

struct AppMainView: View {
    @ObservedObject var viewModel: AppMainViewModel = AppMainViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                characterListView
                Divider()
                bottomToolbar
            }
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            viewModel.fetchDataIfNeeded()
        }
        .actionSheet(isPresented: $viewModel.showsSortActionSheet) {
            sortActionSheet
        }
    }
}

// MARK: - View

private extension AppMainView {
    @ViewBuilder var characterListView: some View {
        if !viewModel.characters.isEmpty {
            CharactersListView(characters: $viewModel.characters, sortMethod: $viewModel.sortMethod)
        } else if !viewModel.characterErrors.isEmpty {
            FetchRetryView(errors: viewModel.characterErrors, onRetry: {
                viewModel.requestData()
            })
            .frame(maxHeight: .infinity)
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
    
    var bottomToolbar: some View {
        HStack {
            Button(action: viewModel.setShowsSortActionSheet) {
                Text("Choose Sorting")
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.white)
    }
    
    var sortButton: some View {
        Button(action: viewModel.setShowsSortActionSheet) {
            Text("Choose Sorting")
        }
    }
    
    var sortActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Sort method"),
            message: Text("Choose sorting method"),
            buttons: [
                .default(Text("Episodes Count")) {
                    viewModel.setSortMethod(.episodesCount)
                },
                .default(Text("Name")) {
                    viewModel.setSortMethod(.name)
                },
                .cancel(Text("Cancel")),
            ]
        )
    }
}

// MARK: - Preview

struct AppMainView_Previews: PreviewProvider {
    static var previews: some View {
        AppMainView()
    }
}
