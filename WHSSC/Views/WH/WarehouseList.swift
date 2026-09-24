//
//  WarehouseList.swift
//  WHSSC
//
//  Created by Dan on 9/23/26.
//

import SwiftUI

struct WarehouseListDetails: Codable, Identifiable {
    var id: String { rhid }
    var rhid: String
    var lotnumber: String
    var wh: String
    var binno: String
    var datetransfer: String
    var prepared: String
    var verified: String
}

struct WarehouseList: View {
    
    let wh: String
    
    @State private var warehouselistdet: [WarehouseListDetails] = []
    
    //MARK: Search Box
    @State private var searchText = ""
    
    var filteredWarehouseList: [WarehouseListDetails] {
        if searchText.isEmpty {
            return warehouselistdet
        }
        
        return warehouselistdet.filter { item in
            item.lotnumber.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    if warehouselistdet.isEmpty {
                        Text("Loading, Please wait... ")
                    } else {
                        HStack {
                            Text("WH-\(wh)")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        ScrollView(.vertical, showsIndicators: true) {
                            ForEach(filteredWarehouseList) { item in
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(Color.clear)
                                        .cornerRadius(10)
                                    HStack {
                                        ZStack {
                                            Rectangle()
                                                .frame(width: 40, height: 40)
                                                .foregroundStyle(Color.green.opacity(0.15))
                                                .cornerRadius(10)
                                            Image(systemName: "shippingbox.fill")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(Color.green)
                                        }
                                        VStack(alignment: .leading) {
                                            Text("\(item.lotnumber)")
                                                .bold()
                                            Text("\(item.datetransfer)")
                                                .font(.footnote)
                                                .foregroundStyle(Color.secondary)
                                        }
                                        Spacer()
                                    }
                                }
                                .contextMenu {
                                    Label("\(item.rhid)", systemImage: "ellipsis.curlybraces")
                                    Label("\(item.prepared)", systemImage: "person")
                                    Label("\(item.verified)", systemImage: "person.fill")
                                }
                                
                                Divider()
                            }
                        }
                    }
                }
                .padding(20)
            }
            .searchable(text: $searchText, prompt: "Search lot number or bin")
            .task {
                await getWHListDetails(wh: wh)
            }
            //MARK: Searchbox
        }
    }
    
    @MainActor
    func getWHListDetails(wh: String) async {
        let urlString = "https://ops.stellarseedscorp.org/App/Warehouse/v2/get_whlist_details.php?wh=\(wh)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode([WarehouseListDetails].self, from: data)
            warehouselistdet = result
        } catch {
            print("Error: ", error.localizedDescription)
        }
    }
}

#Preview {
    WarehouseList(wh: "2")
}
