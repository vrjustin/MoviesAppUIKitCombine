//
//  HTTPClient.swift
//  MoviesAppUIKit
//
//  Created by Justin Maronde on 9/9/24.
//

import Foundation
import Combine

enum NetworkError: Error {
    case badURL
}

class HTTPClient {
    
    func fetchMovies(search: String) -> AnyPublisher<[Movie], Error> {
        
        guard let encodedSearch = search.urlEncoded else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        let url = URL(string: "https://www.omdbapi.com/?s=\(encodedSearch)&page=2&apiKey=xxxxxx")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .map(\.search)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<[Movie], Error> in
                return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        
    }
    
}
