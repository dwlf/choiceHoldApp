import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Data")) {
                Button(action: {
                    // Perform export data action
                    print("Export data...")
                }) {
                    Text("Export Data")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationBarTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
