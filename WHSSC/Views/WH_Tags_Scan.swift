//
//  WH_Tags_Scan.swift
//  STREAM
//
//  Created by Dan on 8/26/26.
//

import SwiftUI

struct QRDataTags: Codable {
    let type: String
    let tagid: Int
    let rhid: Int
    let lotno: String
    let jbno: String
    let kg: Double
    let api: String
}

struct WH_Tags_Scan: View {
    
    let tagid: String
    let sessionid: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var qrdata: QRDataTags?
    
    @State private var showScanner = false
    @State private var qrCode = ""
    
    @State private var showAlertError: Bool = false
    @State private var showSheetPleaseWait: Bool = false
    @State private var showSetPosition: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                QRScannerView { code in
                    qrCode = code
                    getQRData(codedata: qrCode)
                }
                .ignoresSafeArea()
            }
        }
        .alert("Error Notice", isPresented: $showAlertError) {
            Button("Try Again") {
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        } message: {
            Text("Please make sure you scan the correct tag.")
        }
        
        // MARK: - Open Sheet Alert
        .sheet(isPresented: $showSheetPleaseWait) {
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            }
            .interactiveDismissDisabled()
        }
        .navigationDestination(isPresented: $showSetPosition) {
            WH_SetPosition()
        }
    }
    
    func getQRData(codedata: String) {
        
        print(codedata)
        showScanner = false
        
        guard let data = codedata.data(using: .utf8) else {
            return
        }
        do {
            let decoded = try JSONDecoder().decode(QRDataTags.self, from: data)

            qrdata = decoded
            
            let stringtagid = String(decoded.tagid)
            
            print("Tagid: \(stringtagid) == The Tagid: \(tagid)")
            
            if stringtagid != tagid {
                showAlertError = true
            } else {
                showSheetPleaseWait = true
                saveTagandCheck(tagid: tagid, jbno: decoded.jbno, kg: decoded.kg)
            }            
           
       } catch {
           print("❌ Invalid QR:", error)
       }
    }
    
    func saveTagandCheck(tagid: String, jbno: String, kg: Double) {
        
        guard let url = URL(string: "https://ops.stellarseedscorp.org/App/Warehouse/save_new_tags.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "tagid": tagid,
            "sessionid": sessionid,
            "jbno": jbno,
            "kg": kg
        ] as [String : Any]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let data = data {
                
                print(String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)  ?? "")
                
                if String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) == "newtag" {
                    DispatchQueue.main.async {
                        showSheetPleaseWait = false
//                        dismiss()
                        showSetPosition = true
                    }
                }
            }
            
        }.resume()
    }
}

#Preview {
    WH_Tags_Scan(tagid: "", sessionid: "")
}
