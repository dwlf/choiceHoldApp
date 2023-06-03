import SwiftUI
import CoreData

struct AddBookView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var publicationYear = 1999
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name of book:", text: $title)
                    TextField("Author's name:", text: $author)
                }
                Section {
                    Button("Save") {
                        let newBook = CHBook2(context: moc)
                        newBook.id = UUID()
                        newBook.title = title
                        newBook.author = author
                        
                        try? moc.save()
                        dismiss()
                    }
                }
            }
        }.navigationTitle("Add Book")
        
    }
}
