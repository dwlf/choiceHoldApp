import SwiftUI
import CoreData

struct AddBookView: View {
    var book: CHBook?
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var title: String
    @State private var rating: Int

    init(book: CHBook? = nil) {
        _title = State(initialValue: book?.title ?? "")
        _rating = State(initialValue: Int(book?.rating ?? 1))
        self.book = book
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                Stepper(value: $rating, in: 1...5) {
                    Text("Rating: \(rating)")
                }
                Button(action: addBook) {
                    Text(book == nil ? "Add Book" : "Update Book")
                }
            }
            .navigationBarTitle(book == nil ? "Add Book" : "Update Book")
        }
    }

    func addBook() {
        let bookToUpdateOrCreate = book ?? CHBook(context: managedObjectContext)
        bookToUpdateOrCreate.title = title
        bookToUpdateOrCreate.rating = Int16(rating)

        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
}
