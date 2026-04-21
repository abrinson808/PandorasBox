//
//  DataFetcher.swift
//  PandorasBox
//
//  Created by Alex Brinson on 3/31/26.
//

import Foundation

struct DataFetcher{
    let tmdbBaseURL = APIConfig.shared?.tmdbBaseURL
    let tmdbAPIKey = APIConfig.shared?.tmdbAPIKey
    
    
    func fetchTitles(for media:String, by type:String, with title:String? = nil) async throws -> [Title] {
        let fetchTitlesURL = try buildURL(media: media, type: type, searchPhrase: title)
        
        guard let fetchTitlesURL = fetchTitlesURL else {
            throw NetworkError.urlBuildFailed
        }
    
        print(fetchTitlesURL)
        var titles = try await fetchAndDecode(url: fetchTitlesURL, type: TMDBAPIObject.self).results

        Constants.addPosterPath(to: &titles)
        for title in titles {
            if title.mediaType == nil {
                title.mediaType = media
            }
        }
        return titles 
    }
    
    
    func fetchTrailerID(for titleId: Int, mediaType: String) async throws -> String {
        guard let baseURL = tmdbBaseURL else {
            throw NetworkError.missingConfig
        }
        guard let apiKey = tmdbAPIKey else {
            throw NetworkError.missingConfig
        }

        let path = "3/\(mediaType)/\(titleId)/videos"
        guard let url = URL(string: baseURL)?
            .appending(path: path)
            .appending(queryItems: [URLQueryItem(name: "api_key", value: apiKey)]) else {
            throw NetworkError.urlBuildFailed
        }

        let response = try await fetchAndDecode(url: url, type: TMDBVideoResponse.self)
        let trailer = response.results.first { $0.site == "YouTube" && $0.type == "Trailer" }
            ?? response.results.first { $0.site == "YouTube" }
        return trailer?.key ?? ""
    }
    
    func fetchTitleDetail(for titleId: Int, mediaType: String) async throws -> TitleDetailResponse {
        guard let baseURL = tmdbBaseURL else {
            throw NetworkError.missingConfig
        }
        guard let apiKey = tmdbAPIKey else {
            throw NetworkError.missingConfig
        }

        let path = "3/\(mediaType)/\(titleId)"
        guard let url = URL(string: baseURL)?
            .appending(path: path)
            .appending(queryItems: [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "append_to_response", value: "credits,watch/providers,similar")
            ]) else {
            throw NetworkError.urlBuildFailed
        }

        return try await fetchAndDecode(url: url, type: TitleDetailResponse.self)
    }
    
    func fetchAndDecode<T:Decodable>(url:URL, type: T.Type) async throws -> T {
        let (data,urlResponse) = try await URLSession.shared.data(from: url)
        
        guard let response = urlResponse as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badURLResponse(underlyingError: NSError(
                domain: "DataFetcher",
                code: (urlResponse as? HTTPURLResponse)?.statusCode ?? -1,
                userInfo: [NSLocalizedDescriptionKey: "Invaild HTTP Response"]))
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }
    
    private func buildURL(media:String,type:String, searchPhrase:String? = nil) throws -> URL? {
        guard let baseURL = tmdbBaseURL else {
            throw NetworkError.missingConfig
        }
        guard let apiKey = tmdbAPIKey else {
            throw NetworkError.missingConfig
        }
        
        var path:String
        
        if type == "trending" {
            path = "3/\(type)/\(media)/day"
        } else if type == "top_rated" || type == "upcoming" {
            path = "3/\(media)/\(type)"
        } else if type == "search" {
            path = "3/\(type)/\(media)"
        } else {
            throw NetworkError.urlBuildFailed
        }
        
        var urlQueryItems = [
            URLQueryItem(name:"api_key", value: apiKey)
        ]
        
        if let searchPhrase {
            urlQueryItems.append(URLQueryItem(name:"query", value: searchPhrase))
        }
        
        guard let url = URL(string: baseURL)?
            .appending (path: path)
            .appending (queryItems: urlQueryItems) else {
            throw NetworkError.urlBuildFailed
        }
        
        return url
    }
}
