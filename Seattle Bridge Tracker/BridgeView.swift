//
//  BridgeView.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/31/22.
//

import SwiftUI
import URLImage
import MapKit
import SwiftUIMap
import SwiftUIX
import Mcrich23_Toolkit
import SwiftUIAlert

struct BridgeView: View {
    @Binding var bridge: Bridge
    @ObservedObject var contentViewModel = ContentViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var isMapHorizantal: Bool = false
    init(bridge: Binding<Bridge>) {
        self._bridge = bridge
    }
    var body: some View {
        ZStack {
            if #available(iOS 15, *) {
                AsyncImage(url: bridge.imageUrl) { image in
                    image
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .fill(alignment: Alignment.center)
                        .clipped()
                        .ignoresSafeArea()
                } placeholder: {
                    Color.white
//                    Image(systemName: "photo")
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .fill(alignment: Alignment.center)
//                        .foregroundColor(.gray)
//                        .clipped()
//                        .ignoresSafeArea()
                }
            } else {
                URLImage(bridge.imageUrl) { image in
                    image
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .fill(alignment: Alignment.center)
                        .clipped()
                        .ignoresSafeArea()
                }
            }
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Circle()
                            .frame(width: 40, height: 40)
                            .clipped()
                            .foregroundColor(Color(.systemBackground))
                            .overlay(Image(systemName: "arrow.backward")
                                .foregroundColor(Color.primary)
                                .font(.title3), alignment: .center)
                            .frame(alignment: .leading)
                            .clipped()
                    }
                    .accessibilityIdentifier("Back")
                    .accessibilityHint(Text("Back"))
                    .hoverEffect(SwiftUI.HoverEffect.highlight)
                    .padding()
                    Spacer()
                    Button {
                        contentViewModel.fetchData(repeatFetch: false)
                    } label: {
                        Circle()
                            .frame(width: 40, height: 40)
                            .clipped()
                            .foregroundColor(Color(.systemBackground))
                            .overlay(Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color.primary)
                                .font(.title3), alignment: .center)
                            .clipped()
                    }
                    .accessibilityHint(Text("Refresh"))
                    .hoverEffect(SwiftUI.HoverEffect.highlight)
                    .padding()
                    Button {
                        contentViewModel.toggleSubscription(for: bridge)
                    } label: {
                        Circle()
                            .frame(width: 40, height: 40)
                            .clipped()
                            .foregroundColor(Color(.systemBackground))
                            .overlay(Image(systemName: "bell.fill")
                                .foregroundColor(bridge.subscribed ? Color.yellow : Color.primary)
                                .font(.title3), alignment: .center)
                            .clipped()
                    }
                    .accessibilityHint(Text("Subscribe to Notifications"))
                    .hoverEffect(SwiftUI.HoverEffect.highlight)
                    .padding()
                }
                .padding(.vertical, 76)
                .padding(.horizontal, 24)
                .foregroundColor(Color.white)
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 11) {
                        Text(bridge.name)
                            .font(.system(size: 24, weight: .medium, design: .default))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clipped()
                        HStack {
                            Tag(backgroundColor: .blue, text: bridge.bridgeLocation)
                            switch bridge.status {
                            case .up:
                                Tag(backgroundColor: .red, text: bridge.status.rawValue.capitalized)
                            case .down:
                                Tag(backgroundColor: .green, text: bridge.status.rawValue.capitalized)
                            case .maintenance:
                                Tag(backgroundColor: .yellow, text: bridge.status.rawValue.capitalized)
                            case .unknown:
                                Tag(backgroundColor: .yellow, text: bridge.status.rawValue.capitalized)
                            }
                        }
                        map
                            .frame(maxWidth: (isMapHorizantal ? 0 : .infinity), maxHeight: (isMapHorizantal ? 0 : .infinity))
                    }
                    map
                        .frame(maxWidth: (!isMapHorizantal ? 0 : .infinity), maxHeight: (!isMapHorizantal ? 0 : .infinity))
                }
                .padding(.horizontal, 24)
                Spacer()
                    .frame(height: 100)
                    .clipped()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .navigationBarHidden(true)
        }
        .onAppear {
            getIsMapHorizantal(orientation: UIDevice.current.orientation)
            contentViewModel.fetchData(repeatFetch: false)
        }
        .onRotate { orientation in
            getIsMapHorizantal(orientation: orientation)
        }
    }
    var map: some View {
        AnnotationMapView(zoom: .constant(0.05), coordinates: .constant(LocationCoordinate(latitude: bridge.latitude, longitude: bridge.longitude)), points: .constant([Annotations(title: bridge.name, subtitle: "", location: .coordinates(LocationCoordinate(latitude: bridge.latitude, longitude: bridge.longitude)), glyphImage: .assetImage("bridge-icon"))]))
            .isUserInteractionEnabled(false)
            .pointsOfInterest(.excludingAll)
            .accessibilityHint(Text("Map"))
            .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onTapGesture {
                SwiftUIAlert.show(title: "Open Bridge?", message: "Do you want to open \(bridge.name) in maps?", preferredStyle: .alert, actions: [UIAlertAction(title: "Open", style: .default, handler: { _ in
                    UIApplication.shared.open(bridge.mapsUrl)
                }), UIAlertAction(title: "Cancel", style: .cancel)])
            }
    }
    func getIsMapHorizantal(orientation: UIDeviceOrientation) {
        if UIDevice.current.userInterfaceIdiom == .phone && [UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight, UIDeviceOrientation.portraitUpsideDown].contains(orientation) {
            self.isMapHorizantal = true
        } else if [UIDeviceOrientation.faceDown, UIDeviceOrientation.faceUp].contains(orientation) {
        } else {
            self.isMapHorizantal = false
        }
    }
}

struct BridgeView_Previews: PreviewProvider {
    static var previews: some View {
        BridgeView(
            bridge: .constant(
                Bridge(id: UUID(),
                       name: "Ballard Bridge",
                       status: .down,
                       imageUrl: URL(string: "https://s3-media0.fl.yelpcdn.com/bphoto/rq2iSswXqRp5Nmp7MIEVJg/o.jpg")!,
                       mapsUrl: URL(string: "https://maps.apple.com/?address=Ballard%20Bridge,%20Seattle,%20WA%20%2098199,%20United%20States&ll=47.657044,-122.376245&q=Ballard%20Bridge&_ext=EiYpoLms1YbTR0AxFkGkn4GYXsA5Ho/SMa3UR0BBNmKBHaeXXsBQBA%3D%3D")!,
                       address: "Ballard Bridge, Seattle, WA 98199, United States",
                       latitude: 47.65704,
                       longitude: -122.37624,
                       bridgeLocation: "Seattle, Wa",
                       subscribed: false)
            )
        )
    }
}

struct Tag: View {
    @State var backgroundColor: Color
    @State var text: String
    var body: some View {
        Text(text)
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .foregroundColor(Color.white)
            .background(backgroundColor)
            .cornerRadius(12)
            .padding(.top, 8)
    }
}
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
