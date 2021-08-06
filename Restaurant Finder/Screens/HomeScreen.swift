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
    @FocusState private var locInputFocused: Bool
    
    @State var loading = false
    @State var restaurants = [YelpBusiness]()
    
    @State var restaurantModalShown = false
    @State private var selectedRestaurant: YelpBusiness?
    
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors:[.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Restaurant finder!")
                    .font(.system(size: 32, weight: .bold, design: .rounded)).padding()
                
                HStack {
                    Text("Location").bold()
                    
                    Spacer()
                    
                    TextField("Location", text: $locationInputText).focused($locInputFocused).multilineTextAlignment(.trailing).disabled(loading)
                }.frame(width: 280, height: 50)
                
                Button(action: findRestaurant) {
                    HStack {
                        if loading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(.gray)))
                        } else {
                            Label("Find restaurant", systemImage: "magnifyingglass")
                        }
                    }
                    .frame(width: 280, height: 50)
                    .background(Color.white)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .cornerRadius(10)
                }
                .alert(isPresented: $noApiKeyAlertShown) {
                    Alert(
                        title: Text("No API key"),
                        message: Text("No API key was found! Sorry for the inconvenience."),
                        dismissButton: .default(Text("Got it!"))
                    )
                }
                .alert(isPresented: $noRestaurantsFoundShown) {
                    Alert(title: Text("No restaurants found"), message: Text("There were no restaurants find in your area. Please try again later."), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $networkErrorAlertShown) {
                    Alert(title: Text("No internet connection"), message: Text("We failed to find a restaurant for you, please check your internet connection and try again later."), dismissButton: .default(Text("OK")))
                }.alert(isPresented: $noLocationAlertShown) {
                    Alert(title: Text("No location"), message: Text("Please fill in your location so we can find a restaurant for you."), dismissButton: .default(Text("OK")))
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
        locInputFocused = false
        
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
        
        let parameters = YelpParams(location: locationInputText, categories: "restaurants")
        
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
//                        print(selectedRestaurant?.isClosed)
                    }
                case .failure(_):
                    networkErrorAlertShown = true
                }
            }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
