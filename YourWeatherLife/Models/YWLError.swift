//
//  YWLError.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/19/22.
//

import Foundation

enum YWLError: Error {
  case wrongDataFormat(error: Error)
  case missingData
  case creationError
  case batchInsertError
  case batchDeleteError
  case persistentHistoryChangeError
  case unexpectedError(error: Error)
}

extension YWLError: LocalizedError {
  var errorDescription: String? {
    switch self {
      case .wrongDataFormat(let error):
        return NSLocalizedString("Could not decode the fetched data. \(error.localizedDescription)", comment: "")
      case .missingData:
        return NSLocalizedString("Found and will discard data missing properties.", comment: "")
      case .creationError:
        return NSLocalizedString("Failed to create a new object.", comment: "")
      case .batchInsertError:
        return NSLocalizedString("Failed to execute a batch insert request.", comment: "")
      case .batchDeleteError:
        return NSLocalizedString("Failed to execute a batch delete request.", comment: "")
      case .persistentHistoryChangeError:
        return NSLocalizedString("Failed to execute a persistent history change request.", comment: "")
      case .unexpectedError(let error):
        return NSLocalizedString("Received unexpected error. \(error.localizedDescription)", comment: "")
    }
  }
}

extension YWLError: Identifiable {
  var id: String? {
    errorDescription
  }
}
