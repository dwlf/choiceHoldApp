import SwiftUI
import CoreData

struct BookDetailView: View {
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
        .navigationTitle(book.title ?? "Unknown Title")
        .padding()
    }
}
