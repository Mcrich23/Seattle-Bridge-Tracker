//
//  NotificationPreferencesAd.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI

struct NotificationPreferencesAd: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemGroupedBackground)
            BannerAds()
                .padding()
                .frame(alignment: .center)
        }
        .frame(height: Utilities.areAdsDisabled ? 0 : nil)
    }
}

struct NotificationPreferencesAd_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesAd()
    }
}