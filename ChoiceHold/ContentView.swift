import SwiftUI

struct ContentView: View {
    @State private var showingAddBookView = false
    @State private var books = [
        Book(title: "Book 1", rating: 3),
        Book(title: "Book 2", rating: 4),
        Book(title: "Book 3", rating: 5)
    ]

    var body: some View {
        NavigationView {
            List(books) { book in
                VStack(alignment: .leading) {
                    Text(book.title)
                    Text("Rating: \(book.rating)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitle("Books")
            .navigationBarItems(trailing: Button(action: {
                showingAddBookView = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddBookView) {
                AddBookView(books: $books)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
