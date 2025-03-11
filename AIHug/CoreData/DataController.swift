import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Generations")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
}
