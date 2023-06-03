import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: CHBook.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CHBook.title, ascending: true)]
    ) var books: FetchedResults<CHBook>

    var body: some View {
        NavigationView {
            List {
                ForEach(books, id: \.self) { book in
                    NavigationLink(destination: AddBookView(book: book)) {
                        Text(book.title ?? "Unknown title")
                    }
                }
                .onDelete(perform: deleteBook)
            }
            .navigationBarTitle("Books")
            .navigationBarItems(trailing: NavigationLink(destination: AddBookView()) {
                Image(systemName: "plus")
            })
        }
    }

    func deleteBook(at offsets: IndexSet) {
        for index in offsets {
            let book = books[index]
            managedObjectContext.delete(book)
        }

        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
}
