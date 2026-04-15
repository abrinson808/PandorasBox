//
//  Errors.swift
//  PandorasBox
//
//  Created by Alex Brinson on 3/31/26.
//

import Foundation

enum APIConfigError: Error, LocalizedError {
    case fileNotFound
    case dataLoadingFailed(underlyingError: Error)
    case decodingFailed(underlyingError: Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The file containing the API configuration was not found."
        case .dataLoadingFailed(underlyingError: let error):
            return "Failed to load the data containing the API configuration: \(error.localizedDescription)."
        case .decodingFailed(underlyingError: let error):
            return "Failed to decode the data containing the API configuration: \(error.localizedDescription)."
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case badURLResponse(underlyingError: Error)
    case missingConfig
    case urlBuildFailed
    
    var errorDescription: String? {
        switch self {
        case .badURLResponse(underlyingError: let error):
            return "The URL session returned an invalid response: \(error.localizedDescription)."
        case .missingConfig:
            return "The network request was missing the required API configuration."
        case .urlBuildFailed:
            return "The network request could not be constructed into a valid URL."
        }
    }
}
