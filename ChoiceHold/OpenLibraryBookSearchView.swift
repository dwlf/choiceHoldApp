import SwiftUI
import OpenLibrarySwiftSearchClient

struct OpenLibraryBookSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = OpenLibraryBookSearchViewModel()

    var body: some View {
        VStack {
            TextField("Search for books", text: $viewModel.query)
                .padding()
                .border(Color.gray, width: 0.5)
                .onChange(of: viewModel.query) { _ in
                    viewModel.searchBooks()
                }
            
            List(viewModel.searchResults, id: \.key) { book in
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.headline)
                    Text("Author: \(book.author_name?.first ?? "Unknown")")
                    if let urlString = book.url, let url = URL(string: urlString) {
                        Link("OpenLibrary Link", destination: url)
                    } else {
                        Text("No URL available")
                    }
                }
            }
        }
        .navigationTitle("Book Search")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
