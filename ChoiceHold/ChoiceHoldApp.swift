//
//  ChoiceHoldApp.swift
//  ChoiceHold
//
//  Created by Lloyd Dewolf on 6/2/23.
//

import SwiftUI
import CoreData

@main
struct ChoiceHoldApp: App {
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChoiceHoldDM")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}

struct Previews_ChoiceHoldApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
