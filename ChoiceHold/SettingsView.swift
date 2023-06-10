import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc

    @State private var isExporting = false

    var body: some View {
        Form {
            Section(header: Text("Data")) {
                Button(action: {
                    // Perform export data action
                    isExporting = true
                }) {
                    Text("Export Data")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationBarTitle("ChoiceHold Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: CustomFileDocument(content: generateCSVData()),
            contentType: UTType.commaSeparatedText,
            defaultFilename: "reviews.csv"
        ) { result in
            // Handle export completion
            switch result {
            case .success(let url):
                print("Exported file: \(url)")
            case .failure(let error):
                print("Error exporting file: \(error)")
            }
            isExporting = false
        }
    }

    private func generateCSVData() -> String {
        var csvText = "ID,Notes,Rating,Topic,Book Title\n"

        let fetchRequest: NSFetchRequest<CHReview> = CHReview.fetchRequest()

        do {
            let reviews = try moc.fetch(fetchRequest)
            for review in reviews {
                let id = review.id?.uuidString ?? ""
                let notes = review.notes ?? ""
                let rating = String(review.rating)
                let topic = review.topic ?? ""
                let bookTitle = review.book?.title ?? ""

                let newLine = "\(id),\(notes),\(rating),\(topic),\(bookTitle)\n"
                csvText.append(newLine)
            }

            return csvText
        } catch {
            print("Error exporting reviews: \(error)")
        }

        return ""
    }
}

struct CustomFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    var content: String

    init(content: String = "") {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let fileContent = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        content = fileContent
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = content.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }

        return FileWrapper(regularFileWithContents: data)
    }
}
