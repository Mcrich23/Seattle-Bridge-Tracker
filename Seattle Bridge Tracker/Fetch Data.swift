//
//  Fetch Data from Twitter.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import Foundation
import Firebase
import HTTPStatusCodes

enum HttpError: Error {
    case badResponse
    case badURL
}

class TwitterFetch {
    private var url: URL? {
        if Utilities.isFastlaneRunning, let bundleUrl = Bundle.main.url(forResource: "DummyPromo", withExtension: "json") {
            return bundleUrl
        } else if Utilities.appType == .AppStore {
            guard let urlString = Utilities.remoteConfig["fetchUrl"].stringValue else { return nil }
            return URL(string: urlString)
        } else {
            guard let urlString = Utilities.remoteConfig["betaFetchUrl"].stringValue else { return nil }
            return URL(string: urlString)
        }
    }
    
    func fetchTweet(errorHandler: @escaping (HTTPStatusCode) -> Void, completion: @escaping ([Response]) -> Void) {
        do {
            
            guard let url else { return }
            
            var request = URLRequest(url: url,
                                     timeoutInterval: 5.0)
            
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    if error?.localizedDescription.range(of: "Could not connect to the server.") != nil {
                        ConsoleManager.printStatement("Could not connect to the server!")
                        errorHandler(.networkConnectTimeoutError)
                        completion([])
                    } else /*if error?.localizedDescription.range(of: "A server with the specified hostname could not be found.") != nil*/ {
                        ConsoleManager.printStatement("A server with the specified hostname could not be found.")
                        errorHandler(.notFound)
                        completion([])
                    }
                    
                    return
                }
                
                if let response = response as? HTTPURLResponse, !((200 ... 299) ~= response.statusCode) {
                    ConsoleManager.printStatement("❌ Status code is \(response.statusCode)")
                    errorHandler(HTTPStatusCode(rawValue: response.statusCode) ?? .notFound)
                    completion([])
                    return
                }
                
                guard let data = data else {
                    completion([])
                    return
                }
                
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try jsonDecoder.decode([Response].self, from: data)
                    
                    completion(result)
                } catch {
                    ConsoleManager.printStatement("error = \(error)")
                }
            }
            task.resume()
        }
    }
}
