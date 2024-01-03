//
//  APIError.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import Foundation

enum APIError: Error, CustomStringConvertible {
    case badRequest
    case badResponse(statusCode: Int)
    case url(URLError?)
    case parsing(DecodingError?)
    case other(Error?)
    case unknown
    
    var localizedDescription: String {
        // user feedback
        switch self {
        case .badRequest, .parsing, .unknown:
            return "Sorry, something went wrong."
        case .badResponse(_):
            return "Sorry, the connection to our server failed."
        case .other(let error):
            return error?.localizedDescription ?? "Sorry, something went wrong"
        case .url(let error):
            return error?.localizedDescription ?? "Something went wrong."
        }
    }

    var description: String {
        //info for debugging
        switch self {
        case .unknown: return "unknown error"
        case .badRequest: return "invalid Request"
        case .url(let error):
            return error?.localizedDescription ?? "url session error"
        case .parsing(let error):
            return "parsing error \(error?.localizedDescription ?? "")"
        case .other(let error):
            return error?.localizedDescription ?? "Sorry, something went wrong"
        case .badResponse(statusCode: let statusCode):
            return "bad response with status code \(statusCode)"
        }
    }
}
