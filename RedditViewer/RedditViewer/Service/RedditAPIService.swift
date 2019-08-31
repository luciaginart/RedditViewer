//
//  RedditAPIService.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import Foundation

enum RedditAPIServiceResponseError: Error {
    case network
    case decoding
    case path
}

struct RedditAPIService {
    private static let session = URLSession.shared
    private static var urlComponents: URLComponents {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "reddit.com"
        component.path = "/r/anime/top.json"
        
        return component
    }
    
    static func fetchPost(after parameter: String? = nil,
                          completion: @escaping (Result<RedditData, RedditAPIServiceResponseError>) -> Void) {
        
        var urlComponents = self.urlComponents
        
        if let parameter = parameter {
            urlComponents.queryItems = [URLQueryItem(name: "after", value: parameter)]
        }
        
        guard let url = urlComponents.url else {
            completion(Result.failure(RedditAPIServiceResponseError.path))
            return
        }
        
        session.dataTask(with: url, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let data = data,
                error == nil
                else {
                    completion(Result.failure(RedditAPIServiceResponseError.network))
                    return
            }
            
            guard let decodedResponse = try? JSONDecoder().decode(RedditData.self, from: data) else {
                completion(Result.failure(RedditAPIServiceResponseError.decoding))
                return
            }
            
            completion(Result.success(decodedResponse))
        }).resume()
    }
}
