//
//  WhDetails.swift
//  WHSSC
//
//  Created by Dan on 9/24/26.
//

import SwiftUI

struct WhDetailsHeader: Codable, Identifiable {
    var id: String
    var sessionid: String
    var lotnumber: String
    var rhid: String
    var originalsite: String
    var transfersite: String
    var datetransfer: String
    var prepared: String
    var verified: String
}

struct WhDetailsTags: Codable, Identifiable {
    var id: String { tagid }
    var tagid: String
    var sessionid: String
    var jbno: String
    var quantity: String
}

struct WhDetails: View {
    
    let sessionid: String
    
    //MARK: Arrays
    @State private var whdetailsheader: [WhDetailsHeader] = []
    @State private var whdetailstags: [WhDetailsTags] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Batch Details") {
                        HStack(alignment: .top) {
                            VStack {
                                LogoView(logoname: "list.bullet")
                            }
                            .padding(.top, 3)
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    Text("Lot Number")
                                        .font(.footnote)
                                        .foregroundStyle(Color.secondary)
                                    Text("\(whdetailsheader.first?.lotnumber ?? "NA")")
                                    
                                }
                                Divider()
                                VStack(alignment: .leading) {
                                    Text("Date Transferred")
                                        .font(.footnote)
                                        .foregroundStyle(Color.secondary)
                                    Text("\(whdetailsheader.first?.datetransfer ?? "NA")")
                                    
                                }
                                Divider()
                                HStack(spacing: 10) {

                                    VStack(alignment: .leading) {
                                        Text("Original Site")
                                            .font(.footnote)
                                            .foregroundStyle(Color.secondary)
                                        Text("WH\(whdetailsheader.first?.originalsite ?? "0")")
                                        
                                    }
                                    Divider()
                                    VStack(alignment: .leading) {
                                        Text("Transfer Site")
                                            .font(.footnote)
                                            .foregroundStyle(Color.secondary)
                                        Text("WH\(whdetailsheader.first?.transfersite ?? "0")")
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("Tags Details") {
                        ForEach(Array(whdetailstags.enumerated()), id: \.element.id) { index, item in
                            HStack {
                                LogoViewNumber(numberx: "\(index + 1)")
                                VStack(alignment: .leading) {
                                    Text("\(item.jbno)")
                                    HStack {
                                        Text("\(item.quantity) KG")
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    Section("Personnel") {
                        HStack(alignment: .top) {
                            LogoView(logoname: "person.fill")
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Verified By")
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    Text("\(whdetailsheader.first?.verified ?? "NA")")
                                }
                                Divider()
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Received By")
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    Text("\(whdetailsheader.first?.prepared ?? "NA")")
                                }
                            }
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("\(whdetailsheader.first?.sessionid ?? "NA")")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
        }
        .task {
            await getHeader(sessionid: sessionid)
            await getTags(sessionid: sessionid)
        }
    }
    
    @MainActor
    func getHeader(sessionid: String) async {
        guard let url = URL(string: "https://ops.stellarseedscorp.org/App/Warehouse/v2/get_all_batchdetails.php?type=1&sessionid=\(sessionid)") else {
            print("Error URL Header")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode([WhDetailsHeader].self, from: data)
            whdetailsheader = result
//            print("Result Dan: ", result)
        } catch {
            print("Error Fetching Data", error.localizedDescription)
        }
    }
    
    @MainActor
    func getTags(sessionid: String) async {
        guard let url = URL(string: "https://ops.stellarseedscorp.org/App/Warehouse/v2/get_all_batchdetails.php?type=2&sessionid=\(sessionid)") else {
            print("Error URL Header")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode([WhDetailsTags].self, from: data)
            whdetailstags = result
            print("Result Tags: ", result)
        } catch {
            print("Error Fetching Data Tags", error.localizedDescription)
        }
    }
}

struct LogoView: View {
    
    var logoname: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 40, height: 40)
                .cornerRadius(8)
                .foregroundStyle(Color.green)
            Image(systemName: logoname)
                .foregroundStyle(Color.white)
                .bold()
        }
    }
}

struct LogoViewNumber: View {
    
    var numberx: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 40, height: 40)
                .cornerRadius(8)
                .foregroundStyle(Color.green)
            Text("\(numberx)")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.white)
        }
    }
}

#Preview {
    WhDetails(sessionid: "CAF95CE0-DF41-4A4B-8982-E26E7BE24A0D")
}
