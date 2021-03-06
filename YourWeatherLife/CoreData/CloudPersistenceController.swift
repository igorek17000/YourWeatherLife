//
//  CloudPersistenceController.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import CoreData
import OSLog

class CloudPersistenceController {
  
  static let shared = CloudPersistenceController()
  
  static let preview: CloudPersistenceController = {
    let result = CloudPersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    //    for _ in 0..<10 {
    //      let newItem = Item(context: viewContext)
    //      newItem.timestamp = Date()
    //    }
    //    do {
    //      try viewContext.save()
    //    } catch {
    //      let nsError = error as NSError
    //      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //    }
    return result
  }()
  
  private let inMemory: Bool
  
  lazy var container: NSPersistentCloudKitContainer = {
    
    let container = NSPersistentCloudKitContainer(name: "YourWeatherLifeiCloud")
    
    guard let description = container.persistentStoreDescriptions.first else {
      fatalError("Failed to retrieve a persistent store description.")
    }
    
    let storesURL = description.url?.deletingLastPathComponent()
    description.url = storesURL?.appendingPathComponent("cloud.sqlite")
    
    if inMemory {
      description.url = URL(fileURLWithPath: "/dev/null")
    }
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    container.viewContext.automaticallyMergesChangesFromParent = true
    return container
  }()
  
  init(inMemory: Bool = false) {
    self.inMemory = inMemory
  }
}
