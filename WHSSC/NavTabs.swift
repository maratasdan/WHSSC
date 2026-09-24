//
//  NavTabs.swift
//  WHSSC
//
//  Created by Dan on 9/23/26.
//

import SwiftUI

struct NavTabs: View {
    var body: some View {
        TabView {
            NavigationStack {
                ContentView()
                    .navigationTitle("Dashboard")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
        }
        .tint(.green)
    }
}

#Preview {
    NavTabs()
}
