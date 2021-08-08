//
//  HomeScreen.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 02/08/2021.
//

import SwiftUI
import Alamofire

struct HomeScreen: View {
    @State var noApiKeyAlertShown = false
    @State var noRestaurantsFoundShown = false
    @State var networkErrorAlertShown = false
    @State var noLocationAlertShown = false
    
    @State var locationInputText = ""
//    @FocusState private var locInputFocused: Bool
    
    @State var searchType: SearchParam = .random
    @State var searchTerm = ""
    
    @State var loading = false
    @State var restaurants = [YelpBusiness]()
    
    @State var restaurantModalShown = false
    @State private var selectedRestaurant: YelpBusiness?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors:[.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
            VStack {
                Text("app-name")
                    .font(.system(size: 32, weight: .bold, design: .rounded)).padding()
                
                HStack {
                    Label("location", systemImage: "location").font(Font.body.bold())
                    
                    Spacer()
                    
                    TextField("location", text: $locationInputText).multilineTextAlignment(.trailing).disabled(loading).onAppear(perform: {
                        if let locationString = UserDefaults.standard.string(forKey: "location") {
                            locationInputText = locationString
                        }
                    })
                }.padding(.bottom).frame(width: 280, height: 50)
                
                Text("search-type").bold().frame(maxWidth: 280, alignment: .leading)
                
                Picker("search-type", selection: $searchType) {
                    Text("random").tag(SearchParam.random)
                    Text("with-search-term").tag(SearchParam.withSearchTerm)
                }.padding(.bottom).pickerStyle(SegmentedPickerStyle()).frame(width: 280)
                
                if searchType == .withSearchTerm {
                    HStack {
                        Label("search-term", systemImage: "magnifyingglass").font(Font.body.bold())
                        
                        Spacer()
                        
                        TextField("search-term", text: $searchTerm).multilineTextAlignment(.trailing)
                    }.frame(width: 280, height: 50)

                }
                
                Button(action: findRestaurant) {
                    HStack {
                        if loading {
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
                .alert(isPresented: $noApiKeyAlertShown) {
                    Alert(
                        title: Text("no-api-key-title"),
                        message: Text("no-api-key-message"),
                        dismissButton: .default(Text("ok"))
                    )
                }
                .alert(isPresented: $noRestaurantsFoundShown) {
                    Alert(
                        title: Text("no-restaurants-title"),
                        message: Text("no-restaurants-message"),
                        dismissButton: .default(Text("ok"))
                    )
                }
                .alert(isPresented: $networkErrorAlertShown) {
                    Alert(
                        title: Text("no-internet-title"),
                        message: Text("no-internet-message"),
                        dismissButton: .default(Text("ok"))
                    )
                }.alert(isPresented: $noLocationAlertShown) {
                    Alert(title: Text("no-location-title"), message: Text("no-location-message"), dismissButton: .default(Text("ok")))
                }
            }
        }.sheet(isPresented: $restaurantModalShown) {
            RestaurantView(restaurant: $selectedRestaurant)
        }
    }
    
    func didDismiss() {
        restaurantModalShown = false
    }
    
    func buttonTapped() {
        
    }
    
    func findRestaurant() {
        if locationInputText.trimmingCharacters(in: .whitespaces).count == 0 {
            noLocationAlertShown = true
            return;
        }
        
        if loading {
            return;
        }
        UserDefaults.standard.set(locationInputText, forKey: "location")
        hideKeyboard()
//        locInputFocused = false
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        print("pressed")
        
        loading = true
        
        guard let apiKey = Bundle.main.infoDictionary?["YELP_API_KEY"] else {
            noApiKeyAlertShown = true
            loading = false
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)"
        ]
        
        var parameters = YelpParams(location: locationInputText, categories: "restaurants")
        
        switch Locale.current.languageCode! {
        case "nl":
            parameters.locale = "nl_NL"
        case "en":
            parameters.locale = "en_US"
        default:
            parameters.locale = "en_US"
        }
        
        if searchType == .withSearchTerm {
            parameters.term = searchTerm
        }
        
        
        AF.request("https://api.yelp.com/v3/businesses/search", parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: YelpBusinessResponse.self) { response in
                //                debugPrint(response.result)
                //                debugPrint(response.value)
                loading = false
                switch response.result {
                    
                case .success(_):
                    if response.value?.total == 0 {
                        noRestaurantsFoundShown = true
                        return;
                    }
                    
                    restaurants = response.value?.businesses ?? []
                    
                    guard let randomRestaurant = response.value?.businesses.randomElement() else {
                        noRestaurantsFoundShown = true
                        return;
                    }
                    
                    debugPrint(randomRestaurant.name)
                    
                    DispatchQueue.main.async {
                        selectedRestaurant = randomRestaurant
                        restaurantModalShown.toggle()
                    }
                    
                case .failure(_):
                    networkErrorAlertShown.toggle()
                }
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
