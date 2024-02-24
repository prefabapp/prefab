//
//  Client.swift
//  prefab
//
//  Created by Kelly Plummer on 2/22/24.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

public enum HTTPResponseError: Error {
    // Throw when a response is not found
    case notFound(response: String)

    // Throw when a response is too many requests
    case tooManyRequests(response: String)
    
    // Throw whe a response is forbidden
    case forbidden(response: String)
    
    // Throw in all other cases
    case unexpected(response: String, code: Int)
}

public enum UninitializeClientError: Error {
    case propertyIsNotSet(property: String)
}

public class Client {
    var host: String = ""
    var port: String = ""
    var scheme: String = ""
    
    private static var shared: Client = Client()
        
    static func initShared(host: String, port: String, scheme: String) -> Client {
        shared.host = host
        shared.port = port
        shared.scheme = scheme
        
        return shared
    }
    
    static func getShared() throws -> Client {
        switch "" {
        case shared.host:
            throw UninitializeClientError.propertyIsNotSet(property: "host")
        case shared.port:
            throw UninitializeClientError.propertyIsNotSet(property: "port")
        case shared.scheme:
            throw UninitializeClientError.propertyIsNotSet(property: "scheme")
        default:
            return shared
        }
    }
    
    func get(path: String) async throws -> String {
        let request = HTTPRequest(method: .get, scheme: self.scheme, authority: "\(self.host):\(self.port)", path: path)
        let (data, response) = try await URLSession.shared.data(for: request)
        let body = String(decoding: data, as: UTF8.self)
        guard response.status == .ok else {
            switch response.status {
            case .notFound:
                throw HTTPResponseError.notFound(response: body)
            case .tooManyRequests:
                throw HTTPResponseError.tooManyRequests(response: body)
            case .forbidden:
                throw HTTPResponseError.forbidden(response: body)
            default:
                throw HTTPResponseError.unexpected(response: body, code: response.status.code)
            }
            
        }
        return body
    }
    
    func put(path: String, data: Codable) async throws -> String {
        let json = try JSONEncoder().encode(data)
        
        let request = HTTPRequest(method: .put, scheme: self.scheme, authority: "\(self.host):\(self.port)", path: path)
        let (data, response) = try await URLSession.shared.upload(for: URLRequest(httpRequest: request)!, from: json)
        let body = String(decoding: data, as: UTF8.self)
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.httpResponse!.status == .ok else {
                switch httpResponse.httpResponse!.status {
                case .notFound:
                    throw HTTPResponseError.notFound(response: body)
                case .tooManyRequests:
                    throw HTTPResponseError.tooManyRequests(response: body)
                case .forbidden:
                    throw HTTPResponseError.forbidden(response: body)
                default:
                    throw HTTPResponseError.unexpected(response: body, code: httpResponse.httpResponse!.status.code)
                }
            }
        }
        return body
    }
}
