//
//  MovieListViewModel.swift
//  MoviesAppUIKit
//
//  Created by Justin Maronde on 9/9/24.
//

import Foundation
import Combine

class MovieListViewModel {
    
    @Published private(set) var movies: [Movie] = []
    @Published var loadingCompleted: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    private var searchSubject = CurrentValueSubject<String, Never>("")
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
        setupSearchPublisher()
    }
    
    private func setupSearchPublisher() {
        searchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.loadMovies(search: searchText)
            }.store(in: &cancellables)
    }
    
    func setSearchText(_ searchText: String) {
        searchSubject.send(searchText)
    }
    
    func loadMovies(search: String) {
        httpClient.fetchMovies(search: search)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.loadingCompleted = true
                    print("Finished")
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] movies in
                self?.movies = movies
            }.store(in: &cancellables)

    }
    
}
