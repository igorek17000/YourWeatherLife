//
//  APIsProvider.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/18/22.
//

import Foundation
import CoreData
import OSLog

struct APIsProvider {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "APIsProvider")
  
  static let shared = APIsProvider()
  
  func fetchAPIs() async throws {
    let apiKey = APISettings.fetchAPISettings().apiKey
    let secretKey = APISettings.fetchAPISettings().secretKey
    let urlBase = APISettings.fetchAPISettings().urlBase
    let apisEndpoint = APISettings.fetchAPISettings().apisEndpoint
    let signature = CryptoUtilities.signRequest(input: apiKey, secretKey: secretKey)
    
    let apisURL = URL(string: urlBase + apisEndpoint)!
    var urlRequest = URLRequest(url: apisURL)
    urlRequest.setValue(apiKey, forHTTPHeaderField: "apiKey")
    urlRequest.setValue(signature, forHTTPHeaderField: "signature")
    
    let session = URLSession.shared
    guard let (data, response) = try? await session.data(for: urlRequest),
          let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200
    else {
      logger.debug("Failed to received valid response and/or data.")
      throw YWLError.missingData
    }
    
    do {
      let jsonDecoder = JSONDecoder()
      let apiDecoder = try jsonDecoder.decode(APIDecoder.self, from: data)
      let apiList = apiDecoder.apisList
      logger.debug("Received \(apiList.count) records.")
      
      logger.debug("Start importing data to the store...")
      try await importAPIs(from: apiList)
      logger.debug("Finished importing data.")
    } catch {
      throw YWLError.wrongDataFormat(error: error)
    }
  }
  
  private func importAPIs(from apisList: [APIProperties]) async throws {
    guard !apisList.isEmpty else { return }
    
    let taskContext = newTaskContext()
    taskContext.name = "importContext"
    taskContext.transactionAuthor = "importAPIs"
    
    try await taskContext.perform {
      let batchInsertRequest = self.newBatchInsertRequest(with: apisList)
      if let fetchResult = try? taskContext.execute(batchInsertRequest),
         let batchInsertResult = fetchResult as? NSBatchInsertResult,
         let success = batchInsertResult.result as? Bool, success {
        return
      }
      logger.debug("Failed to execute batch insert request.")
      throw YWLError.batchInsertError
    }
    logger.debug("Successfully inserted data.")
  }
  
  private func newBatchInsertRequest(with apiList: [APIProperties]) -> NSBatchInsertRequest {
    var index = 0
    let total = apiList.count
    let batchInsertRequest = NSBatchInsertRequest(entity: API.entity(), dictionaryHandler: { dictionary in
      guard index < total else { return true }
      dictionary.addEntries(from: apiList[index].dictionaryValue)
      index += 1
      return false
    })
    return batchInsertRequest
  }
  
  private func newTaskContext() -> NSManagedObjectContext {
    let container = PersistenceController.shared.container
    let taskContext = container.newBackgroundContext()
    taskContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy //adjust this to affect data overwriting
    return taskContext
  }
  
  
}
