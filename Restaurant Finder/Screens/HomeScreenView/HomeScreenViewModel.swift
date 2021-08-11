//
//  HomeScreenViewModel.swift
//  HomeScreenViewModel
//
//  Created by Wisse Hes on 11/08/2021.
//

import Foundation
import Alamofire
import UIKit

final class HomeScreenViewModel: ObservableObject {
    @Published var activeAlert: HomescreenAlert = .noApiKey
    @Published var alertShown = false
    
    @Published var locationInputText = ""
    
    @Published var searchType: SearchParam = .random
    @Published var searchTerm = ""
    
    @Published var maxRange: MaxRange = .noLimit
    
    @Published var loading = false
    @Published var restaurants: [YelpBusiness] = []
    
    @Published var restaurantModalShown = false
    @Published var selectedRestaurant: YelpBusiness?
    
    func showAlert(alert: HomescreenAlert)  {
        activeAlert = alert
        alertShown = true
    }
    
    func reload() {
        restaurantModalShown = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let randomRestaurant = self.restaurants.randomElement()
            self.selectedRestaurant = randomRestaurant
            self.restaurantModalShown = true
        }
    }
    
    func findRestaurant() {
        if locationInputText.trimmingCharacters(in: .whitespaces).count == 0 {
            showAlert(alert: .noLocation)
            return;
        }
        
        if loading {
            return;
        }
        UserDefaults.standard.set(locationInputText, forKey: "location")
        hideKeyboard()
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        print("pressed")
        
        loading = true
        
        guard let apiKey = Bundle.main.infoDictionary?["YELP_API_KEY"] else {
            showAlert(alert: .noApiKey)
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
        
        if maxRange != .noLimit {
            parameters.radius = maxRange.rawValue
        }
        
        
        AF.request("https://api.yelp.com/v3/businesses/search", parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: YelpBusinessResponse.self) { response in
                //                debugPrint(response.result)
                //                debugPrint(response.value)
                self.loading = false
                switch response.result {
                    
                case .success(_):
                    if response.value?.total == 0 {
                        print("no restaurants")
                        self.showAlert(alert: .noRestaurantsFound)
                        return;
                    }
                    
                    self.restaurants = response.value?.businesses ?? []
                    
                    guard let randomRestaurant = response.value?.businesses.randomElement() else {
                        self.showAlert(alert: .noRestaurantsFound)
                        return;
                    }
                    
                    debugPrint(randomRestaurant.name)
                    
                    DispatchQueue.main.async {
                        self.selectedRestaurant = randomRestaurant
                        self.restaurantModalShown = true
                    }
                    
                case .failure(_):
                    self.showAlert(alert: .networkError)
                }
            }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
