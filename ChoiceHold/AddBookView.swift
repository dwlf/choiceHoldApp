import SwiftUI

struct AddBookView: View {
    @State private var title = ""
    @State private var rating = 3
    @Binding var books: [Book]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    Picker("Rating", selection: $rating) {
                        ForEach(1..<6) {
                            Text("\($0) Stars")
                        }
                    }
                }
                Button("Add Book") {
                    let newBook = Book(title: title, rating: rating)
                    books.append(newBook)
                    title = ""
                    rating = 3
                }
            }
            .navigationTitle("Add Book")
        }
    }
}

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView(books: .constant([]))
    }
}
