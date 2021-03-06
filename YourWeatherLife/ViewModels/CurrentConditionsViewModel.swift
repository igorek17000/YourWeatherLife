//
//  CurrentConditionsViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation
import OSLog

class CurrentConditionsViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "CurrentConditionsViewModel")
  
  var data = Data()
  
  //MARK: Home
  
  @Published var current: Current?
  
  func fetchCurrentWeather(override: Bool = false) async {
    guard override || GetAllData.shared.fetchCurrentConditions() else { return }
    let api = await DataService().fetchPrimaryAPIFromLocal()
    var url = ""
    switch api.shortName {
      case "tgw":
        url = tgw.getCurrentWeatherURL(api)
      case "aowm":
        url = aowm.getCurrentWeatherURL(api)
      default:
        logger.error("Couldn't determine the API by shortname. 😭")
    }
    guard !url.isEmpty else { return }
    let urlRequest = URLRequest(url: URL(string: url)!) //forced is ok since using guard right before to check for empty URL string
    do {
      guard let (data, response) = try? await URLSession.shared.data(for: urlRequest), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
      else {
        logger.debug("Failed to received valid response and/or data.")
        throw YWLError.missingData
      }
      self.data = data
    } catch {
      logger.error("Could not fetch current conditions. ⛈")
    }
    
    let jsonDecoder = JSONDecoder()
    do {
      switch api.shortName {
        case "tgw":
          let tgwDecoder = try jsonDecoder.decode(TGW_CurrentConditionsDecoder.self, from: data)
          DispatchQueue.main.async {
            self.current = tgwDecoder.current
          }
        case "aowm":
          let aowmDecoder = try jsonDecoder.decode(AOWM_CurrentConditionsDecoder.self, from: data)
          DispatchQueue.main.async {
            self.current = aowmDecoder.current
          }
        default:
          self.logger.error("Couldn't determine the Decoder by shortname. 😭")
      }
    } catch {
      logger.error("Could not decode current conditions. 🌧 \(error.localizedDescription)")
    }
  }
}
