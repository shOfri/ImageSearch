//
//  SearchViewModel.swift
//  ImageSearch
//
//  Created by Ofri Shadmi on 16/05/2023.
//

import Foundation

class SearchViewModel {
    private let apiKey = "36415293-c3b729105ad9d5d43a76f4745"
    private let pageSize = 20
    
    var searchText: String = ""
    var currentPage: Int = 1
    var images: [Image] = []
    var savedImages: [Image] = []
    
    func performSearch(completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://pixabay.com/api/?q=\(searchText)&key=\(apiKey)&page=\(currentPage)&per_page=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SearchResult.self, from: data)
                    //self.images = result.hits
                    
                    for image in result.hits{
                        self.images.append(image)
                    }
                    
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func loadMoreImages(completion: @escaping (Result<Void, Error>) -> Void) {
        currentPage += 1
        performSearch(completion: completion)
    }
}

struct Image: Codable {
    let id: Int
    let webformatURL: String
    let webformatWidth: Int
    let webformatHeight: Int
}

struct SearchResult: Codable {
    let hits: [Image]
}


