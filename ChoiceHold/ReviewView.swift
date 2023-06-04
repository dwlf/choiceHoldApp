import SwiftUI
import CoreData

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
