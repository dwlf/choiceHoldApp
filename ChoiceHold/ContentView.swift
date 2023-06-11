import SwiftUI
import CoreData
import OpenLibrarySwiftSearchClient

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var books: FetchedResults<CHBook2>

    @State private var showingSettingsScreen = false
    @State private var showingOpenLibSearchView = false
    @State private var showingBookSearchScreen = false
    @State private var searchText = ""
    @State private var lastTypingTime: Date = Date()
    @State private var showingAddBookPrompt = false

    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .center) {
                    TextField("Search...", text: $searchText)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 18))
                        .padding(.bottom, 10)
                    Spacer()
                    Image("choiceKeepLogo33x35")
                        .cornerRadius(5)
                        .padding(.bottom, 10)
                }.padding(.top, 10)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .onChange(of: searchText) { value in
                        lastTypingTime = Date() // store the time when the user typed something
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // wait for 0.5 seconds
                            // if after 0.5 seconds the last typing time hasn't been updated, the user has stopped typing
                            if Date().timeIntervalSince(lastTypingTime) >= 0.5 && searchText.count >= 3 {
                                showingAddBookPrompt = true
                            } else {
                                showingAddBookPrompt = false
                            }
                        }
                    }

                Text("Count: \(books.count)")

                List {
                    ForEach(filteredBooks(), id: \.self) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookView(book: book)
                        }
                    }
                    .onDelete(perform: deleteBooks)
                }

                Button(action: {
                    showingOpenLibSearchView.toggle()
                }, label: {
                    Text("Not finding what you were looking for?")
                })
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .opacity(showingAddBookPrompt ? 1 : 0)
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showingOpenLibSearchView.toggle()
                        } label: {
                            Label("Add Book", systemImage: "plus")
                        }

                        Button {
                            showingSettingsScreen.toggle()
                        } label: {
                            Image(systemName: "gearshape")
                        }

                        // New Book Search button
                        Button {
                            showingBookSearchScreen.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingOpenLibSearchView) {
                searchOpenLibView(searchText: searchText.trimmingCharacters(in: .whitespaces))
            }
            .sheet(isPresented: $showingSettingsScreen) {
                NavigationView {
                    SettingsView()
                }
            }
            .sheet(isPresented: $showingBookSearchScreen) {
                NavigationView {
                    OpenLibraryBookSearchView()
                }
            }
            .onAppear(perform: populateData)
        }
    }
    
    func filteredBooks() -> [CHBook2] {
        if searchText.isEmpty {
            return Array(books)
        } else {
            return books.filter { book in
                let bookTitleContainsSearchText = book.title?.lowercased().contains(searchText.lowercased()) ?? false
                let bookReviewsContainSearchText = book.reviews?.contains(where: { review in
                    let review = review as? CHReview
                    return review?.topic?.lowercased().contains(searchText.lowercased()) ?? false
                }) ?? false
                return bookTitleContainsSearchText || bookReviewsContainSearchText
            }
        }
    }
    
    func populateData() {
        let fetchRequest: NSFetchRequest<CHReview> = CHReview.fetchRequest()
        let reviewCount = try? moc.count(for: fetchRequest)
        
        if books.count == 0 {
            if reviewCount != 0 {
                // Delete orphaned reviews
                if let reviews = try? moc.fetch(fetchRequest) {
                    for review in reviews {
                        moc.delete(review)
                    }
                }
            }
           // createDummyBooks()
        }
    }
    
    func createDummyBooks() {
        let bookTitles = ["Harry Potter and the Chamber of Secrets"]
        
        for (index, title) in bookTitles.enumerated() {
            let fetchRequest: NSFetchRequest<CHBook2> = CHBook2.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", title)
            
            if let _ = try? moc.fetch(fetchRequest).first {
                continue // Book already exists, skip to the next iteration
            }
            
            let book = CHBook2(context: moc)
            book.id = UUID()
            book.title = title
            
            // Fetch book details from Open Library API
            OpenLibrarySwiftSearchClient.findClosestBook(title: title, author: nil) { result in
                switch result {
                case .success(let openLibraryBook):
                    if let authorName = openLibraryBook.author_name?.first {
                        fetchAuthorDetails(authorKey: authorName) { author in
                            let chBook = CHBook2() // Replace CHBook2 with your CHBook2 struct or class
                            chBook.author = author // Assign the author to CHBook2's author property
                            saveContext()
                        }
                    } else {
                        let chBook = CHBook2() // Replace CHBook2 with your CHBook2 struct or class
                        chBook.author = "Unknown Author" // Assign a default author value
                        saveContext()
                    }
                case .failure(let error):
                    print("Failed to fetch book details: \(error)")
                }
            }
            
            createDummyReviews(for: book)
        }
    }

    func fetchAuthorDetails(authorKey: String, completion: @escaping (String) -> Void) {
        let authorURLString = "https://openlibrary.org/authors/\(authorKey).json"
        
        guard let authorURL = URL(string: authorURLString) else {
            completion("Unknown Author")
            return
        }
        
        URLSession.shared.dataTask(with: authorURL) { data, response, error in
            if let error = error {
                print("Failed to fetch author details: \(error)")
                completion("Unknown Author")
                return
            }
            
            guard let data = data else {
                completion("Unknown Author")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let authorResponse = try decoder.decode(OpenLibraryAuthorResponse.self, from: data)
                completion(authorResponse.name)
            } catch {
                print("Failed to decode author details: \(error)")
                completion("Unknown Author")
            }
        }.resume()
    }

    struct OpenLibraryAuthorResponse: Codable {
        let name: String
    }
    
    func createDummyReviews(for book: CHBook2) {
        for i in 1...3 {
            let fetchRequest: NSFetchRequest<CHReview> = CHReview.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "book.title == %@ AND topic == %@", book.title!, "Topic \(book.title!) \(i)")
            
            if let _ = try? moc.fetch(fetchRequest).first {
                continue // Review already exists, skip to the next iteration
            }
            
            let review = CHReview(context: moc)
            review.id = UUID()
            review.topic = "Topic \(book.title!) \(i)"
            review.notes = "Notes \(book.title!) \(i)"
            review.rating = Int16(i)
            review.book = book
        }
    }
    
    func deleteBooks(at offsets: IndexSet) {
        offsets.forEach { index in
            let book = books[index]
            
            // Delete all reviews associated with the book
            if let reviews = book.reviews as? Set<CHReview> {
                for review in reviews {
                    moc.delete(review)
                }
            }
            
            // Delete the book
            moc.delete(book)
        }
        saveContext()
    }
    
    func saveContext() {
        do {
            try moc.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

struct BookView: View {
    let book: CHBook2

    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title ?? "Unknown Title")
            Text(book.author ?? "Unknown Author")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let reviews = book.reviews as? Set<CHReview> {
                ForEach(Array(reviews), id: \.self) { review in
                    ReviewView(review: review)
                        .padding(.leading)
                }
            }
        }
        .listRowInsets(EdgeInsets()) // Remove default list row insets
    }
}


