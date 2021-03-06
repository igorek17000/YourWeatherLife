//
//  Home.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/10/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct Home: View {
  
  @StateObject private var globalViewModel = GlobalViewModel()
  @StateObject private var currentConditions = CurrentConditionsViewModel()
  
  @State var override = false
  
  var body: some View {
    
    UITableView.appearance().backgroundColor = .clear
    
    return NavigationView {
      ZStack {
        BackgroundColor()
        VStack {
          List {
            HStack {
              VStack(alignment: .leading) {
                HStack {
                  Text(currentConditions.current?.temperature ?? "88°")
                    .font(.largeTitle)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                  Image(currentConditions.current?.icon ?? "day/113")
                    .padding(.vertical, -32)
                } //end of HStack
                Text(currentConditions.current?.condition ?? "Sunny")
                  .font(.body)
                  .minimumScaleFactor(0.1)
                  .padding(.vertical, -25)
              } //end of VStack
              .padding(.horizontal, 10)
              Spacer()
              VStack(alignment: .trailing) {
                Text("Your Weather")
                  .font(.largeTitle)
                  .lineLimit(1)
                  .minimumScaleFactor(0.1)
                HStack {
                  Image(systemName: "location.fill")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(Color.accentColor)
                  Text(currentConditions.current?.location ?? "Mesa")
                    .font(.body)
                    .minimumScaleFactor(0.1)
                  Image(systemName: "chevron.down")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(Color.accentColor)
                } //end of HStack
              } //end of VStack
              .padding(.horizontal, 10)
            } //end of HStack
            .padding(.bottom, 20)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .task {
              await currentConditions.fetchCurrentWeather(override: override)
              await GetAllData.shared.getAllData()
              override = false
            }
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Morning Commute")) { }
                .opacity(0)
              EventListItem(event: "Morning Commute:", times: "7a - 9a", summary: "75° Clear and dry")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Lunch")) { }
                .opacity(0)
              EventListItem(event: "Lunch:", times: "11a - 12p", summary: "85° Cloudy and 20% chance of rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Afternoon Commute")) { }
                .opacity(0)
              EventListItem(event: "Afternoon Commute:", times: "4p - 6p", summary: "82° Cloudy and 80% chance of rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: DayDetail()) { }
                .opacity(0)
              EventListToday(precipitation: true, precipitationType: "Rain", precipitationTime: "4p", precipitationPercent: "80%", coldestTemp: "68°", coldestTime: "4a", warmestTemp: "83°", warmestTime: "3p", sunriseTemp: "72°", sunriseTime: "7:14a", sunsetTemp: "76°", sunsetTime: "8:13p")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: WeekendDetail()) { }
                .opacity(0)
              EventListWeekend(saturdayHighTemp: "88°", saturdayLowTemp: "75°", saturdaySummary: "Sunny all day", sundayHighTemp: "91°", sundayLowTemp: "79°", sundaySummary: "Sunny morning, cloudy afternoon")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Taco Tuesday")) { }
                .opacity(0)
              EventListCalendarItem(title: "Taco Tuesday Happy Hour on June 21", startTemp: "83°", startTime: "6p", endTemp: "75°", endTime: "9p", aroundSunrise: false, sunriseTemp: "", sunriseTime: "", aroundSunset: true, sunsetTemp: "76°", sunsetTime: "8:15p", precipitation: false, precipitationType: "", precipitationTime: "", precipitationPercent: "", eventWeatherSummary: "Cool and clear with no chance for rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Group Hike")) { }
                .opacity(0)
              EventListCalendarItem(title: "Group hike on June 25", startTemp: "65°", startTime: "6:30a", endTemp: "72°", endTime: "9a", aroundSunrise: true, sunriseTemp: "67°", sunriseTime: "7:10a", aroundSunset: false, sunsetTemp: "", sunsetTime: "", precipitation: true, precipitationType: "rain", precipitationTime: "8a", precipitationPercent: "65%", eventWeatherSummary: "Cold and cloudy with a good chance of rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
          } //end of List
          .listStyle(.plain)
          .refreshable {
            Mixpanel.mainInstance().track(event: "Refresh Pulled")
            await currentConditions.fetchCurrentWeather()
            await GetAllData.shared.getAllData()
          }
        }
        .navigationBarHidden(true)
        
        NavigationLink(destination: DailyEvents(), isActive: $globalViewModel.isShowingDailyEvents) { }
      } //end of VStack
      .onAppear() {
        Mixpanel.mainInstance().track(event: "Home View")
      }
    } //end of NavigationView
    .environmentObject(globalViewModel)
  }
}

struct ListView_Previews: PreviewProvider {
  static var previews: some View {
    Home()
  }
}
