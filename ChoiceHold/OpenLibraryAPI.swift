import Foundation
import os.log

enum OpenLibraryAPIError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case serializationFailed
}

struct OpenLibraryAPI {
    private static let baseURL = "https://openlibrary.org"
    private static let log = OSLog(subsystem: "com.example.OpenLibraryAPI", category: "API")

    static func searchBooks(query: String, completion: @escaping (Result<[OpenLibraryBook], OpenLibraryAPIError>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search.json?title=\(encodedQuery)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                let logMessage = "Request failed: \(error.localizedDescription)"
                os_log("%@, function: %@, line: %d", log: Self.log, type: .error, logMessage, #function, #line)
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                os_log("Invalid response data, function: %@, line: %d", log: Self.log, type: .error, #function, #line)
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(OpenLibrarySearchResponse.self, from: data)
                completion(.success(searchResponse.docs))
            } catch {
                let logMessage = "Serialization failed: \(error.localizedDescription)"
                os_log("%@, function: %@, line: %d", log: Self.log, type: .error, logMessage, #function, #line)
                completion(.failure(.serializationFailed))
            }
        }.resume()
    }
    
    static func getBookDetails(olid: String, completion: @escaping (Result<OpenLibraryBookDetails, OpenLibraryAPIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/books?bibkeys=OLID:\(olid)&format=json&jscmd=data") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let logMessage = "Fetching book details for OLID: \(olid)"
        os_log("%@, function: %@, line: %d", log: Self.log, type: .info, logMessage, #function, #line)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                let logMessage = "Request failed: \(error.localizedDescription)"
                os_log("%@, function: %@, line: %d", log: Self.log, type: .error, logMessage, #function, #line)
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                os_log("Invalid response data, function: %@, line: %d", log: Self.log, type: .error, #function, #line)
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let bookDetailsResponse = try decoder.decode([String: OpenLibraryBookDetails].self, from: data)
                
                if let bookDetails = bookDetailsResponse["OLID:\(olid)"] {
                    fetchAuthorDetails(authorKeys: bookDetails.authorKey) { result in
                        switch result {
                        case .success(let authorDetails):
                            var updatedBookDetails = bookDetails
                            updatedBookDetails.author = authorDetails.name
                            completion(.success(updatedBookDetails))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    os_log("Book details serialization failed, function: %@, line: %d", log: Self.log, type: .error, #function, #line)
                    completion(.failure(.serializationFailed))
                }
            } catch {
                let logMessage = "Serialization failed: \(error.localizedDescription)"
                os_log("%@, function: %@, line: %d", log: Self.log, type: .error, logMessage, #function, #line)
                completion(.failure(.serializationFailed))
            }
        }.resume()
    }
    
    static func fetchAuthorDetails(authorKeys: [String]?, completion: @escaping (Result<OpenLibraryAuthorDetails, OpenLibraryAPIError>) -> Void) {
        guard let authorKeys = authorKeys else {
            os_log("No author keys provided, function: %@, line: %d", log: Self.log, type: .error, #function, #line)
            completion(.failure(.serializationFailed))
            return
        }
        
        let authorKeyString = authorKeys.joined(separator: ",")
        let authorDetailsURL = "\(baseURL)/api/authors?keys=\(authorKeyString)&format=json"
        
        guard let url = URL(string: authorDetailsURL) else {
            os_log("Invalid author details URL, function: %@, line: %d", log: Self.log, type: .error, #function, #line)
            completion(.failure(.invalidURL))
            return
        }
        
        let logMessage = "Fetching author details for keys: \(authorKeyString)"
        os_log("%@, function: %@, line: %d", log: Self.log, type: .info, logMessage, #function, #line)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                let logMessage = "Request failed: \(error.localizedDescription)"
                os_log("%@, function: %@, line: %d", log: Self.log, type: .error, logMessage, #function, #line)
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                os_log("Invalid response data, function: %@, line: %d", log: Self.log, type: .error, #function, #line)
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let authorDetailsResponse = try decoder.decode([String: OpenLibraryAuthorDetails].self, from: data)
                
                if let authorDetails = authorDetailsResponse.values.first {
                    os_log("Author details fetched successfully, function: %@, line: %d", log: Self.log, type: .info, #function, #line)
                    completion(.success(authorDetails))
                } else {
                    os_log("Author details serialization failed, function: %@, line: %d", log: Self.log, type: .error, #function, #line)
                    completion(.failure(.serializationFailed))
                }
            } catch {
                let logMessage = "Serialization failed: \(error.localizedDescription)"
                os_log("%@, function: %@, line: %d", log: Self.log, type: .error, logMessage, #function, #line)
                completion(.failure(.serializationFailed))
            }
        }.resume()
    }
}

struct OpenLibraryBook: Codable {
    let key: String
    let title: String
    let authorKey: [String]?
    let isbn: [String]?
    let author: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorKey = "author_key"
        case isbn
        case author
        case url
    }
}

struct OpenLibraryBookDetails: Codable {
    let key: String
    let title: String
    let authorKey: [String]?
    let isbn: [String]?
    var author: String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorKey = "author_key"
        case isbn
        case author
    }
}

struct OpenLibrarySearchResponse: Codable {
    let docs: [OpenLibraryBook]
}

struct OpenLibraryAuthorDetails: Codable {
    let key: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
    }
}
