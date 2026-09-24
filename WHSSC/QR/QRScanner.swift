//
//  QRScanner.swift
//  WHSSC
//
//  Created by Dan on 9/23/26.
//

import SwiftUI

// MARK: - QR Data Model

struct QRData: Codable {
    let type: String
    let tagid: Int
    let rhid: Int
    let lotno: String
    let jbno: String
    let kg: Double
    let api: String
}

// MARK: - QR Scanner

struct QRScanner: View {

    @Environment(\.dismiss) private var dismiss

    @State private var qrdata: QRData?
    @State private var qrCode = ""
    @State private var isProcessing = false

    // MARK: - Navigation Variables

    @State private var goToConfirmTag = false
    @State private var goToTags = false
    @State private var goToConfirmTransfer = false

    // MARK: - Body

    var body: some View {

        ZStack {

            QRScannerView { code in

                guard !isProcessing else {
                    return
                }

                isProcessing = true
                qrCode = code

                getQRData(codedata: code)
            }

            if isProcessing {

                ZStack {

                    Color.black.opacity(0.35)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {

                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.3)

                        Text("Processing QR Code...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(25)
                    .background(.black.opacity(0.85))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
            }
        }
        .navigationTitle("QR Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()

        // MARK: - Navigation Destinations

        .navigationDestination(isPresented: $goToConfirmTag) {
            WH_PreviewConfirm(lotno: qrdata?.lotno ?? "", rhid: qrdata?.rhid ?? 0, processtype: qrdata?.type ?? "", jbno: qrdata?.jbno ?? "", kg: qrdata?.kg ?? 0, tagid: qrdata?.tagid ?? 0)
        }

        .navigationDestination(isPresented: $goToTags) {
            WH_Tags(lotno: qrdata?.lotno ?? "")
        }

        .navigationDestination(isPresented: $goToConfirmTransfer) {

            WH_ConfirmTransfer(
                lotno: qrdata?.lotno ?? "",
                rhid: qrdata?.rhid ?? 0,
                processtype: qrdata?.type ?? "",
                jbno: qrdata?.jbno ?? "",
                kg: qrdata?.kg ?? 0,
                tagid: qrdata?.tagid ?? 0
            )
        }

        // MARK: - Reset When Returning

        .onChange(of: goToConfirmTag) { _, newValue in
            if !newValue {
                resetIfNoDestination()
            }
        }

        .onChange(of: goToTags) { _, newValue in
            if !newValue {
                resetIfNoDestination()
            }
        }

        .onChange(of: goToConfirmTransfer) { _, newValue in
            if !newValue {
                resetIfNoDestination()
            }
        }

        // MARK: - Toolbar

        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Decode QR Data

    func getQRData(codedata: String) {

        print("Scanned QR:", codedata)

        guard let data = codedata.data(using: .utf8) else {
            print("Unable to convert QR code to data")
            resetScanner()
            return
        }

        do {

            let decoded = try JSONDecoder().decode(
                QRData.self,
                from: data
            )

            qrdata = decoded

            checkifexist(
                lotnumber: decoded.lotno,
                rhid: decoded.rhid
            )

        } catch {

            print("Invalid QR:", error.localizedDescription)
            resetScanner()
        }
    }

    // MARK: - Check If Tag Exists

    func checkifexist(lotnumber: String, rhid: Int) {

        guard let url = URL(
            string: "https://ops.stellarseedscorp.org/App/Warehouse/check_tag_exist.php"
        ) else {
            print("Invalid API URL")
            resetScanner()
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body: [String: Any] = [
            "rhid": rhid,
            "lotnumber": lotnumber,
            "uuid": UUID().uuidString,
            "step": "1"
        ]

        do {

            request.httpBody = try JSONSerialization.data(
                withJSONObject: body
            )

        } catch {

            print("JSON Encoding Error:", error.localizedDescription)
            resetScanner()
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {

                print("API Error:", error.localizedDescription)

                DispatchQueue.main.async {
                    resetScanner()
                }

                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data,
                  let result = String(
                    data: data,
                    encoding: .utf8
                  )?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                  )
            else {

                print("Invalid API response")

                DispatchQueue.main.async {
                    resetScanner()
                }

                return
            }

            print("API Response:", result)

            DispatchQueue.main.async {

                switch result {

                case "no records":
                    goToConfirmTag = true

                case "Exist":
                    goToTags = true

                case "Exist3":
                    goToConfirmTransfer = true

                default:
                    print("Unexpected API response:", result)
                    resetScanner()
                }
            }

        }.resume()
    }

    // MARK: - Reset Scanner

    func resetIfNoDestination() {

        guard !goToConfirmTag,
              !goToTags,
              !goToConfirmTransfer else {
            return
        }

        resetScanner()
    }

    func resetScanner() {

        qrCode = ""
        qrdata = nil
        isProcessing = false

        print("Scanner reset. Ready for next scan.")
    }
}

#Preview {
    NavigationStack {
        QRScanner()
    }
}
