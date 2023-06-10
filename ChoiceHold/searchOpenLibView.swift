import SwiftUI
import CoreData
import OpenLibrarySwiftSearchClient

struct searchOpenLibView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var olBooks: [OpenLibraryBook] = []

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
                                    case .success(let olBooks):
                                        self.olBooks = olBooks
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
                
                List {
                    ForEach(olBooks, id: \.key) { olBooks in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(olBooks.title)
                                Text(olBooks.author_name?.first ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                let bookToAdd = CHBook2(context: moc)
                                bookToAdd.id = UUID()
                                bookToAdd.title = olBooks.title
                                bookToAdd.author = olBooks.author_name?.first
                                bookToAdd.isbn = olBooks.isbn?.first

                                /// TOFIX
                                if let firstPublishYear = olBooks.first_publish_year {
                                    let publicationYearString = String(firstPublishYear)
                                    bookToAdd.pubYearStr = publicationYearString
                                }
                                
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
                Spacer()
                
                HStack(spacing: 4) {
                    Image("openLibraryLogo")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("Powered, but not affiliated with")
                        .font(.footnote)
                    Link("Open Library", destination: URL(string: "https://openlibrary.org/")!)
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding(.bottom)

            }
            .navigationTitle("Search Open Library")
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
                        case .success(let olBooks):
                            self.olBooks = olBooks
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
}
