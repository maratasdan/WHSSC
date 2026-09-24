//
//  ViewISM.swift
//  WHSSC
//
//  Created by Dan on 9/24/26.
//

import SwiftUI

struct ViewISM: View {
    
    let id: String
    
    var body: some View {
        NavigationStack {
            WebView(url: "https://ops.stellarseedscorp.org/modules/whs/print_ism_app.php?id=\(id)")
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Warehouse")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    OrientationManager.lock(.landscape)
                }
                .onDisappear {
                    OrientationManager.lock(.portrait)
                }
        }
    }
}

#Preview {
    ViewISM(id: "21")
}
