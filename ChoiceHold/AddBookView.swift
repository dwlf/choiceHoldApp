import SwiftUI
import CoreData
import OpenLibrarySwiftSearchClient

struct AddBookView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var publicationYear = 1999
    @State private var books: [OpenLibraryBook] = []

    @State var searchText: String
    @State private var lastTypingTime: Date = Date()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                    .padding(.horizontal)
                    .onChange(of: searchText) { value in
                        lastTypingTime = Date() // store the time when the user typed something
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // wait for 0.5 seconds
                            // if after 0.5 seconds the last typing time hasn't been updated, the user has stopped typing
                            if Date().timeIntervalSince(lastTypingTime) >= 0.5 && searchText.count >= 3 {
                                OpenLibrarySwiftSearchClient.searchBooksByTitleAndAuthor(value, limit: 10) { result in
                                    switch result {
                                    case .success(let books):
                                        self.books = books
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
                
                List {
                    ForEach(books, id: \.key) { book in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title)
                                Text(book.author_name?.first ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                let newBook = CHBook2(context: moc)
                                newBook.id = UUID()
                                newBook.title = book.title
                                newBook.author = book.author_name?.first
                                newBook.isbn = book.isbn?.first

                                newBook.publicationYear = Int16(book.first_publish_year)
                                
                                do {
                                    try moc.save()
                                } catch {
                                    print("Failed to save the book: \(error)")
                                }
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Book")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                if searchText.count >= 3 {
                    OpenLibrarySwiftSearchClient.searchBooksByTitleAndAuthor(searchText, limit: 10) { result in
                        switch result {
                        case .success(let books):
                            self.books = books
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
}
