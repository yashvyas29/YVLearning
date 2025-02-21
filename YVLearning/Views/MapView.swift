//
//  MapView.swift
//  YVLearning
//
//  Created by Yash Vyas on 14/02/22.
//

import MapKit
import SwiftUI

@available(iOS 14.0, *)
struct MapView: View {
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.01))
    let locations = [
        Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]

    var body: some View {
        NavigationView {
            Group {
                if #available(iOS 17.0, *) {
                    Map(initialPosition: .region(mapRegion)) {
                        ForEach(locations) { location in
                            Marker(
                                location.name,
                                systemImage: "location.north.circle",
                                coordinate: location.coordinate
                            )
                        }
                        UserAnnotation { location in
                            Text(location.location?.description ?? "My Location")
                        }
                    }
                    // .mapStyle(.hybrid)
                    .mapControls {
                        MapUserLocationButton()
                        MapPitchToggle()
                        MapCompass()
                        MapScaleView()
                    }
                    .mapControlVisibility(.visible)
                } else {
                    Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            NavigationLink {
                                Text(location.name)
                            } label: {
                                Circle()
                                    .stroke(.red, lineWidth: 3)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                }
            }
            .navigationTitle("London Explorer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    struct Location: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }
}

@available(iOS 14.0, *)
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .previewAsComponent()
    }
}
