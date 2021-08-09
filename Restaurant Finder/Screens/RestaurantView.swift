//
//  RestaurantView.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 02/08/2021.
//

import SwiftUI
import MapKit
import BetterSafariView

struct RestaurantView: View {
    let reload: () -> Void
//    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Binding var restaurant: YelpBusiness?
    
    @State var mapSheetShown = false
    @State var directionSheetShown = false
    @State var browserShown = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if restaurant?.imageURL != nil && restaurant?.imageURL.count != 0 {
                        HStack {
                            Spacer()
                            
                            AsyncImage(
                                url: URL(string: restaurant!.imageURL)!,
                                placeholder: { ProgressView().frame(width: 250.0, height: 250.0) },
                                image: { Image(uiImage: $0).resizable() }
                            )
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(16)
                                .frame(maxHeight: 300.0)
                            
                            
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Text("open")
                        Spacer()
                        Text(restaurant!.isClosed ? "no" : "yes")
                    }
                    
                    HStack {
                        Text(restaurant!.categories.count == 1 ? "category" : "categories")
                        Spacer()
                        Text(restaurant!.categories.map { $0.title }.joined(separator: ", "))
                    }
                    
                    HStack {
                        Text("rating")
                        Spacer()
                        VStack {
                            Image(getRatingImage())
//                            Text(getRatingText())
                            Text("review-count \(restaurant!.reviewCount)", tableName: "Plurals")
                        }
                        
                    }
                    
//                    Button("Show map") {
//                        mapSheetShown.toggle()
//                    }
                    
                    Button("get-directions", action: directionsActionSheet)
                    
//                    Link("Open on Yelp", destination: URL(string: restaurant!.url)!)
                    Button("open-on-yelp") {
                        browserShown = true
                    }.safariView(isPresented: $browserShown) {
                        SafariView(url: URL(string: restaurant!.url)!)
                            .preferredBarAccentColor(.clear)
                            .preferredControlAccentColor(.accentColor)
                            .dismissButtonStyle(.done)
                    }
                }.navigationTitle(Text(restaurant?.name ?? "Unknown")).navigationBarItems(leading: closeButton(), trailing: reloadButton())
                    .sheet(isPresented: $mapSheetShown) {
                        MapView(latitude: restaurant!.coordinates.latitude, longitude: restaurant!.coordinates.longitude, name: restaurant!.name)
                    }
                    .actionSheet(isPresented: $directionSheetShown) {
                        let lat = restaurant!.coordinates.latitude
                        let lon = restaurant!.coordinates.longitude
//                        let add = restaurant!.location.address1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let add = restaurant!.location.displayAddress.joined(separator: ", ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let addString = String(describing: add!)
                        
                        return ActionSheet(title: Text("directions"), message: Text("which-app"), buttons: [
                            .default(Text("google-maps"), action: {
                            let url = URL(string: "comgooglemaps://?q=\(addString)&center=\(lat),\(lon)")!

                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }),
                            .default(Text("apple-maps"), action: openInAppleMaps),
                            .cancel()
                        ])
                    }
            }
        }
    }
    
    func closeButton() -> some View {
        Button("close") {
//            dismiss()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func reloadButton() -> some View {
        Button(action: reload) {
            Label("Retry", systemImage: "arrow.clockwise")
        }
    }
    
    func directionsActionSheet() {
        let googleMapsAvailable = UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")! as URL)
        
        if googleMapsAvailable {
            directionSheetShown.toggle()

        } else {
            openInAppleMaps()
        }
        
    }
    
    func openInAppleMaps() {
        let coordinate = CLLocationCoordinate2DMake(restaurant!.coordinates.latitude, restaurant!.coordinates.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        mapItem.name = restaurant!.name
//      mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
        mapItem.openInMaps()
    }
    
    func getRatingImage() -> String {
        let rating = YelpRating(rawValue: restaurant!.rating)
        return rating?.getImageName() ?? "rating_0"
    }
    
    func getRatingText() -> String {
        let reviews = restaurant!.reviewCount
        
        return "From \(reviews) \(reviews > 1 ? "reviews" : "review")"
    }
}

//struct RestaurantView_Previews: PreviewProvider {
//    static var previews: some View {
//        RestaurantView()
//    }
//}
