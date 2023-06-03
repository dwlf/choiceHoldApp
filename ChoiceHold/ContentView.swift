import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var books: FetchedResults<CHBook2>
    
    @State private var showingAddScreen = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Count: \(books.count)")
                
                List {
                    ForEach(books, id: \.self) { book in
                        VStack(alignment: .leading) {
                            Text(book.title ?? "Unknown Title")
                            Text(book.author ?? "Unknown Author")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(book.reviews?.allObjects as? [CHReview] ?? [], id: \.self) { review in
                                VStack(alignment: .leading) {
                                    Text("Review UUID: \(review.id?.uuidString ?? "Unknown UUID")")
                                    Text("Review Topic: \(review.topic ?? "Unknown Topic")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading)
                            }
                        }
                    }
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
        // Create books
        let bookTitles = ["Title 1", "Title 2", "Title 3", "Title 4"]
        var books = [CHBook2]()

        for (index, title) in bookTitles.enumerated() {
            let fetchRequest: NSFetchRequest<CHBook2> = CHBook2.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", title)

            if let _ = try? moc.fetch(fetchRequest).first {
                // Book already exists, do nothing
            } else {
                // Book does not exist, create it
                let book = CHBook2(context: moc)
                book.id = UUID()
                book.author = "Author \(index + 1)"
                book.isbn = "ISBN \(index + 1)"
                book.language = "Language \(index + 1)"
                book.publicationYear = Int16(2001 + index)
                book.title = title
                books.append(book)
            }
        }

        saveContext()

        // Create reviews
        for book in books {
            for i in 1...3 {
                let fetchRequest: NSFetchRequest<CHReview> = CHReview.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "book.title == %@ AND genre == %@", book.title!, "Topic \(book.title!) \(i)")

                if let _ = try? moc.fetch(fetchRequest).first {
                    // Review already exists, do nothing
                } else {
                    // Review does not exist, create it
                    let review = CHReview(context: moc)
                    review.id = UUID()
                    review.topic = "Topic \(book.title!) \(i)"
                    review.notes = "Notes \(book.title!) \(i)"
                    review.rating = Int16(i)
                    review.book = book
                }
            }
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
