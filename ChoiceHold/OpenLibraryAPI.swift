import Foundation

enum OpenLibraryAPIError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case serializationFailed
}

struct OpenLibraryAPI {
    private static let baseURL = "https://openlibrary.org"

    static func searchBooks(query: String, completion: @escaping (Result<[OpenLibraryBook], OpenLibraryAPIError>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search.json?title=\(encodedQuery)") else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Request failed: \(error)")
                completion(.failure(.requestFailed))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(OpenLibrarySearchResponse.self, from: data)
                completion(.success(searchResponse.docs))
            } catch {
                print("Serialization failed: \(error)")
                completion(.failure(.serializationFailed))
            }
        }.resume()
    }
}

struct OpenLibraryBook: Codable {
    let key: String
    let title: String
    let authorKey: [String]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorKey = "author_key"
    }
}

struct OpenLibrarySearchResponse: Codable {
    let docs: [OpenLibraryBook]
}
