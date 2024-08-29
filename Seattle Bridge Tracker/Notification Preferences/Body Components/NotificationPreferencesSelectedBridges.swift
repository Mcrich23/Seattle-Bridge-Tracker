//
//  NotificationPreferencesSelectedBridges.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI
import Mcrich23_Toolkit

struct NotificationPreferencesSelectedBridges: View {
    @Binding var preference: NotificationPreferences
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    var body: some View {
        HStack {
            Text("Bridges: ")
            Spacer()
            Button {
                Mcrich23_Toolkit.topVC().present {
                    if preferencesModel.preferencesArray.first(where: { $0.id == preference.id }) != nil {
                        NotificationContentView(preference: $preference)
                    }
                }
            } label: {
                if preference.bridgeIds.isEmpty {
                    Text("Select Bridge")
                } else if let bridgeId = preference.bridgeIds.first, let bridge = contentViewModel.allBridges.first(where: { $0.id == bridgeId }), preference.bridgeIds.count == 1 {
                    Text("\(bridge.name), \(bridge.bridgeLocation)")
                } else {
                    Text("\(preference.bridgeIds.count) Bridges Selected")
                }
            }
            .hoverEffect(SwiftUI.HoverEffect.highlight)
        }
    }
}

struct NotificationPreferencesSelectedBridges_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesSelectedBridges(preference: .constant(.defaultPreferences))
    }
}
