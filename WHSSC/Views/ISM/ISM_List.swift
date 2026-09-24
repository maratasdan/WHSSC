//
//  ISM_List.swift
//  WHSSC
//
//  Created by Dan on 9/24/26.
//

import SwiftUI

struct WhISMHeader: Codable, Identifiable {
    var id: String
    var lotno: String
    var originalsite: String
    var transfersite: String
    var binno: String
    var datetransfer: String
    var flagging: String
    var prepared: String
    var verified: String
    var received: String?
    var status: String
    var sessionid: String
    var rhid: String?
    var client_name: String
    var seed_variety: String
    var resolved_bin: String
    var tag_count: String
    var total_kg: String
    var ism_no: String
}

struct ISM_List: View {
    
    //MARK: Array
    @State private var whsimheader: [WhISMHeader] = []
    
    //MARK: Search Box
    @State private var searchText = ""
    
    var filtered_whsimheader: [WhISMHeader] {
        if searchText.isEmpty {
            return whsimheader
        }
        return whsimheader.filter { item in
            item.lotno.localizedCaseInsensitiveContains(searchText) ||
            item.ism_no.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    //MARK: Navigations
    @State private var goTo_ViewISM: Bool = false
    
    var body: some View {
        NavigationStack {
            List(filtered_whsimheader) { item in
                NavigationLink(destination: ViewISM(id: item.id)) {
                    HStack {
                        LogoView(logoname: "list.bullet.rectangle.portrait")
                        VStack(alignment: .leading) {
                            Text("\(item.lotno)")
                            VStack {
                                Text("ID: \(item.ism_no)")
                            }
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            //MARK: Searchbox
            .searchable(text: $searchText, prompt: "Search lot number or ISM Number")
        }
        .task {
            await getwhsimheader()
        }
    }
    
    @MainActor
    func getwhsimheader() async {
        guard let url = URL(string: "https://ops.stellarseedscorp.org/App/Warehouse/v2/get_ISM_list.php") else {
            print("Error URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode([WhISMHeader].self, from: data)
            whsimheader = result
            print("Dan: ",result)
        } catch {
            
        }
    }
}


#Preview {
    ISM_List()
}
