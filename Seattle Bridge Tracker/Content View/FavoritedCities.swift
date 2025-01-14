//
//  FavoriteBridges.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 4/3/23.
//

import Foundation
import SwiftUI

struct FavoritedCities: View {
    @ObservedObject var viewModel = ContentViewModel.shared
    @ObservedObject var favoritesModel = FavoritesModel.shared
    @ObservedObject var adController = AdController.shared
    var body: some View {
        ForEach(favoritesModel.favorites, id: \.self) { key in
            Section {
                VStack {
                    ForEach((viewModel.sortedBridges[key] ?? []).sorted()) { bridge in
                        if #available(iOS 15.0, *) {
                            BridgeRow(bridge: Binding(get: {
                                ConsoleManager.printStatement("get \(bridge)")
                                return bridge
                            }, set: { _ in
                            }))
                            .tag(bridge.name)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.toggleSubscription(for: bridge)
                                } label: {
                                    if bridge.subscribed {
                                        Image(systemName: "bell.slash.fill")
                                    } else {
                                        Image(systemName: "bell.fill")
                                    }
                                }
                            }
                        } else {
                            BridgeRow(bridge: Binding(get: {
                                ConsoleManager.printStatement("get \(bridge)")
                                return bridge
                            }, set: { _ in
                            }))
                            .tag(bridge.name)
                        }
                    }
                    if !adController.areAdsDisabled && !Utilities.isFastlaneRunning {
                        HStack {
                            Spacer()
                            BannerAds()
                            Spacer()
                        }
                    }
                }
            } header: {
                HStack {
                    Text(key)
                    if viewModel.sortedBridges.keys.count >= 3 {
                        Spacer()
                        Button {
                            favoritesModel.toggleFavorite(bridgeLocation: key)
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .imageScale(.medium)
                        }
                    }
                }
            }
        }
    }
}
