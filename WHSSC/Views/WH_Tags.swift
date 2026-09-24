//
//  WH_Tags.swift
//  STREAM
//
//  Created by Dan on 8/26/26.
//

import SwiftUI

struct JBTags: Codable {
    let tagid: String
    let lotno: String
    let jbno: String
    let kg: String?
    let sessionid: String?
    let status: String?
}

struct BatchDataCNTags: Codable, Identifiable {
    let id: String
    let sessionid: String
    let lotnumber: String
    let rhid: String
    let date_created: String
    let wh: String
    let status: String
}

struct WH_Tags: View {
    
    let lotno: String
    
    @State private var jbtags: [JBTags] = []
    @State private var batchdatacntags: [BatchDataCNTags] = []
    
    @State private var showAlertConfirmTransfer: Bool = false
    @State private var gotohome: Bool = false
    @State private var goToFillInfo: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(jbtags.enumerated()), id: \.element.tagid) { index, item in
                    
                    if item.status == "1" {
                        HStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(10)
                                    .foregroundStyle(Color.green.opacity(0.15))

                                Text("\(index + 1)")
                                    .bold()
                            }

                            VStack(alignment: .leading) {
                                Text(item.jbno)

                                Text("Quantity: \(item.kg ?? "0") KG")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }

                    } else {
                        NavigationLink(
                            destination: WH_Tags_Scan(
                                tagid: item.tagid,
                                sessionid: batchdatacntags.first?.sessionid ?? ""
                            )
                        ) {
                            HStack {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(10)
                                        .foregroundStyle(Color.red.opacity(0.15))

                                    Text("\(index + 1)")
                                        .bold()
                                }

                                VStack(alignment: .leading) {
                                    Text(item.jbno)

                                    Text("Quantity: \(item.kg ?? "0") KG")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .alert("Confirmation", isPresented: $showAlertConfirmTransfer) {
            Button("Cancel", role: .close) {
                
            }
            Button("Confirm", role: .confirm) {
                goToFillInfo = true
            }
        } message: {
            Text("Are you sure you want to transfer these tags?")
        }
        .navigationDestination(isPresented: $gotohome) {
            WH_Dashboard()
        }
        .navigationDestination(isPresented: $goToFillInfo) {
            WH_Fill_Info(
                lotnumber: batchdatacntags.first?.lotnumber ?? "",
                sessionID: batchdatacntags.first?.sessionid ?? ""
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    gotohome = true
                }) {
                    Image(systemName: "chevron.backward")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showAlertConfirmTransfer = true
                }) {
                    Image(systemName: "checkmark.circle")
                }
                .tint(Color.green)
            }
        }
        .onAppear() {
            getTagsx(lotno: lotno)
            getBatchInfo(lotnumber: lotno)
            print("lotno: \(lotno)")
        }
    }
    
    func getTagsx(lotno: String) {
        guard let url = URL(string: "https://ops.stellarseedscorp.org/App/Warehouse/get_tags.php") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = "lotnumber=\(lotno)"

        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                
                let result = try JSONDecoder().decode([JBTags].self, from: data)
                
                print("tagsdatareq: \(result)")

                DispatchQueue.main.async {
                    self.jbtags = result
                }
            } catch {
                print(error)
            }

        }.resume()
    }
    
    func getBatchInfo(lotnumber: String) {

        guard let encodedLot = lotnumber.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) else { return }

        let urlString = "https://ops.stellarseedscorp.org/App/Warehouse/v2/check_batch.php?lotno=\(encodedLot)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print("Network error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(
                    [BatchDataCNTags].self,
                    from: data
                )

                DispatchQueue.main.async {
                    self.batchdatacntags = result
                }

            } catch {
                print("Decoding error:", error)
                print(String(data: data, encoding: .utf8) ?? "")
            }

        }.resume()
    }
}

#Preview {
    WH_Tags(lotno: "")
}
