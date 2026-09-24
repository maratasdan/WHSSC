//
//  WH_PreviewConfirm.swift
//  STREAM
//
//  Created by Dan on 8/26/26.
//

import SwiftUI

struct WH_PreviewConfirm: View {
    
    let lotno: String
    let rhid: Int
    let processtype: String
    let jbno: String
    let kg: Double
    let tagid: Int
    
    @State private var showAlertConfirmation: Bool = false
    
    @State private var warehouse: String = ""
    
    @State private var goToTags: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Confirm Batch")
                            .font(.title)
                        Text("Please Select Warehouse")
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .listRowBackground(Color.clear)
                Section("Batch Details") {
                    HStack {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .cornerRadius(10)
                                .foregroundStyle(Color.green.opacity(0.15))
                            Image(systemName: "widget.small")
                        }
                        VStack(alignment: .leading) {
                            Text("\(lotno)")
                            Text("Lot Number")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    HStack {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .cornerRadius(10)
                                .foregroundStyle(Color.green.opacity(0.15))
                            Image(systemName: "waveform.path.ecg.text.page")
                        }
                        VStack(alignment: .leading) {
                            Text("\(processtype)")
                                .textCase(.uppercase)
                            Text("Process Type")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                
                Section("Please Select Warehouse") {
                    HStack {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .cornerRadius(10)
                                .foregroundStyle(Color.green.opacity(0.15))
                            Image(systemName: "house.circle")
                        }
                        VStack(alignment: .leading) {
                            Text("Warehouse 1")
                            Text("STELLAR SEEDS CORP PLANT")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            showAlertConfirmation = true
                            warehouse = "1"
                        }) {
                            Image(systemName: "checkmark.circle.badge.plus")
                        }
                        .tint(Color.green)
                    }
                    
                    HStack {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .cornerRadius(10)
                                .foregroundStyle(Color.green.opacity(0.15))
                            Image(systemName: "house.circle")
                        }
                        VStack(alignment: .leading) {
                            Text("Warehouse 2")
                            Text("STELLAR SEEDS CORP PLANT")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            showAlertConfirmation = true
                            warehouse = "2"
                        }) {
                            Image(systemName: "checkmark.circle.badge.plus")
                        }
                        .tint(Color.green)
                    }
                    
                    HStack {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .cornerRadius(10)
                                .foregroundStyle(Color.green.opacity(0.15))
                            Image(systemName: "house.circle")
                        }
                        VStack(alignment: .leading) {
                            Text("Warehouse 3")
                            Text("STELLAR SEEDS CORP PLANT")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            showAlertConfirmation = true
                            warehouse = "3"
                        }) {
                            Image(systemName: "checkmark.circle.badge.plus")
                        }
                        .tint(Color.green)
                    }
                    
                    HStack {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .cornerRadius(10)
                                .foregroundStyle(Color.green.opacity(0.15))
                            Image(systemName: "house.circle")
                        }
                        VStack(alignment: .leading) {
                            Text("Warehouse 4")
                            Text("STELLAR SEEDS CORP PLANT")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            showAlertConfirmation = true
                            warehouse = "4"
                        }) {
                            Image(systemName: "checkmark.circle.badge.plus")
                        }
                        .tint(Color.green)
                    }
                    
                }
            }
        }
        .alert("Confirmation", isPresented: $showAlertConfirmation) {
            Button("Cancel") {
                
            }
            Button("Confirm") {
                proceedToSaveBatch(lotno: lotno, rhid: rhid, warehousex: warehouse)
            }
            
        } message: {
            Text("Confirm to transfer to warehouse \(warehouse)")
        }
        .navigationDestination(isPresented: $goToTags) {
            WH_Tags(lotno: lotno)
        }
    }
    
    func proceedToSaveBatch(lotno: String, rhid: Int, warehousex: String) {
        
        guard let url = URL(string: "https://ops.stellarseedscorp.org/App/Warehouse/check_tag_exist.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "rhid": rhid,
            "lotnumber": lotno,
            "uuid": UUID().uuidString,
            "step": "2",
            "warehouse": warehousex,
            "jbno": jbno,
            "kg": kg,
            "tagid": tagid
        ] as [String : Any]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let data = data {
                
                if String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) == "newinsert" {
                    goToTags = true
                }
            }
            
        }.resume()
        
    }
}

#Preview {
    WH_PreviewConfirm(lotno: "", rhid: 0, processtype: "", jbno: "", kg: 0, tagid: 0)
}
