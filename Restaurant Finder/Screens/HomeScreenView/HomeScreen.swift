//
//  HomeScreen.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 02/08/2021.
//

import SwiftUI
import Alamofire

struct HomeScreen: View {
    @StateObject var viewModel = HomeScreenViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors:[.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
            VStack {
                Text("app-name")
                    .font(.system(size: 32, weight: .bold, design: .rounded)).padding(20)
                
                HStack {
                    Label("location", systemImage: "location").font(Font.body.bold())
                    
                    Spacer()
                    
                    TextField(LocalizedStringKey("location"), text: $viewModel.locationInputText).multilineTextAlignment(.trailing).disabled(viewModel.loading).onAppear(perform: {
                        if let locationString = UserDefaults.standard.string(forKey: "location") {
                            viewModel.locationInputText = locationString
                        }
                    })
                }.padding(.bottom).frame(width: 280, height: 50)
                
                Text("max-range").bold().frame(maxWidth: 280, alignment: .leading)
                
                Picker("max-range", selection: $viewModel.maxRange) {
                    Text("one-km").tag(MaxRange.oneKm)
                    Text("two-km").tag(MaxRange.twoKm)
                    Text("three-km").tag(MaxRange.threeKm)
                    Text("five-km").tag(MaxRange.fiveKm)
                    Text("no-limit").tag(MaxRange.noLimit)
                }.pickerStyle(SegmentedPickerStyle()).padding(.bottom).frame(width: 280)
                
                Text("search-type").bold().frame(maxWidth: 280, alignment: .leading)
                
                Picker("search-type", selection: $viewModel.searchType) {
                    Text("random").tag(SearchParam.random)
                    Text("with-search-term").tag(SearchParam.withSearchTerm)
                }.padding(.bottom).pickerStyle(SegmentedPickerStyle()).frame(width: 280)
                
                if viewModel.searchType == .withSearchTerm {
                    HStack {
                        Label("search-term", systemImage: "magnifyingglass").font(Font.body.bold())
                        
                        Spacer()
                        
                        TextField(LocalizedStringKey("search-term"), text: $viewModel.searchTerm).multilineTextAlignment(.trailing)
                    }.frame(width: 280, height: 50)

                }
                
                Button(action: viewModel.findRestaurant) {
                    HStack {
                        if viewModel.loading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(.gray)))
                        } else {
                            Label("find-restaurants", systemImage: "magnifyingglass")
                        }
                    }
                    .frame(width: 280, height: 50)
                    .background(Color.white)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .cornerRadius(10)
                }
                .alert(isPresented: $viewModel.alertShown) {
                    switch viewModel.activeAlert {
                    case .noApiKey:
                        return Alert(
                            title: Text("no-api-key-title"),
                            message: Text("no-api-key-message"),
                            dismissButton: .default(Text("ok"))
                        )
                    case .noRestaurantsFound:
                        return Alert(
                            title: Text("no-restaurants-title"),
                            message: Text("no-restaurants-message"),
                            dismissButton: .default(Text("ok"))
                        )
                    case .networkError:
                        return Alert(
                            title: Text("no-internet-title"),
                            message: Text("no-internet-message"),
                            dismissButton: .default(Text("ok"))
                        )
                    case .noLocation:
                        return Alert(
                            title: Text("no-location-title"),
                            message: Text("no-location-message"),
                            dismissButton: .default(Text("ok"))
                        )
                    }
                }
            }
        }.sheet(isPresented: $viewModel.restaurantModalShown) {
            RestaurantView(reload: viewModel.reload, restaurant: $viewModel.selectedRestaurant)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
