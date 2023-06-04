import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var books: FetchedResults<CHBook2>
    
    @State private var showingAddScreen = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search...", text: $searchText)
                    .padding(.horizontal)
                
                Text("Count: \(books.count)")
                
                List {
                    ForEach(books.filter({ searchText.isEmpty ? true : $0.title?.contains(searchText) ?? false }), id: \.self) { book in
                        BookView(book: book)
                    }
                    .onDelete(perform: deleteBooks)
                }
            }
            .navigationTitle("ChoiceHold")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddScreen.toggle()
                    } label: {
                        Label("Add Book", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddScreen) {
                AddBookView()
            }
            .onAppear(perform: populateData)
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
            createDummyBooks()
        }
    }
    
    func createDummyBooks() {
        let bookTitles = ["Title 1", "Title 2", "Title 3", "Title 4"]
        
        for (index, title) in bookTitles.enumerated() {
            let fetchRequest: NSFetchRequest<CHBook2> = CHBook2.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", title)
            
            if let _ = try? moc.fetch(fetchRequest).first {
                continue // Book already exists, skip to the next iteration
            }
            
            let book = CHBook2(context: moc)
            book.id = UUID()
            book.author = "Author \(index + 1)"
            book.isbn = "ISBN \(index + 1)"
            book.language = "Language \(index + 1)"
            book.publicationYear = Int16(2001 + index)
            book.title = title
            
            createDummyReviews(for: book)
        }
        
        saveContext()
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

struct ReviewView: View {
    let review: CHReview
    @Environment(\.managedObjectContext) var moc // Access the moc from the environment

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Review UUID: \(review.id?.uuidString ?? "Unknown UUID")")
                Text("Review Topic: \(review.topic ?? "Unknown Topic")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
                deleteReview()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }

    func deleteReview() {
        moc.delete(review)
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
