//
//  MapView.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 05/08/2021.
//

import SwiftUI
import MapKit

struct City: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct MapView: View {
    @Environment(\.dismiss) var dismiss
    
    let latitude: Double
    let longitude: Double
    let name: String
    
    @State var places: [City] = []
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: places) { place in
                MapPin(coordinate: place.coordinate, tint: .blue)
            }.navigationBarItems(leading: closeButton()).navigationBarTitle(Text(name)).onAppear(perform: addPins).navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func addPins() {
        let newPin = City(latitude: latitude, longitude: longitude)
        places = [newPin]
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
    
    func closeButton() -> some View {
        Button("Close") {
            dismiss()
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
