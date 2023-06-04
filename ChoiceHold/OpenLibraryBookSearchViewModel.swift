import SwiftUI
import Combine

class OpenLibraryBookSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var searchResults: [OpenLibraryBook] = []
    
    private var searchTask: DispatchWorkItem?
    
    func searchBooks() {
        // Cancel the previous search task if it's still running
        searchTask?.cancel()
        
        // Create a new search task
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            if self.query.count >= 3 {
                // Perform the search
                OpenLibraryAPI.searchBooks(query: self.query) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let books):
                            self.searchResults = books
                        case .failure(let error):
                            print("Search failed: \(error)")
                            self.searchResults = []
                        }
                    }
                }
            } else {
                // Reset the search results when the query is less than 3 characters
                self.searchResults = []
            }
        }
        
        // Store the new search task
        searchTask = task
        
        // Schedule the search task with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
}
