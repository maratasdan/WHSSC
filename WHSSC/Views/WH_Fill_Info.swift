//
//  WH_Fill_Info.swift
//  STREAM
//
//  Created by Dan on 9/4/26.
//

import SwiftUI

struct BatchDetailsForISM: Codable, Identifiable {
    var id: String { rhid }
    var rhid: String
    var lot_number: String
    var bin_name: String
    var qf: String
    var wh: String
    var sessionid: String
    var date_now: String
}

struct WH_Fill_Info: View {

    let lotnumber: String
    let sessionID: String
    
    @State private var batchdetailsforism: [BatchDetailsForISM] = []

    @State private var orginalSite: String = ""
    @State private var transferSite: String = ""
    @State private var binno: String = ""
    @State private var datetransfer: String = ""
    @State private var flagging: String = ""

    @State private var preparedby: String = ""
    @State private var verifiedby: String = ""

    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var goToHome: Bool = false

    var body: some View {

        List {

            // MARK: - Header

            Section {

                VStack(alignment: .leading, spacing: 8) {

                    Text("Please complete the following fields")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Fill in the required information below.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            // MARK: - Transfer Information

            Section("Transfer Information") {

                // Lot Number

                HStack {

                    fieldIcon("tag.fill")

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Lot Number")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text(lotnumber)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }

                // Original Site

                HStack {

                    fieldIcon("building.2")

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Original Site")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField("Enter original site", text: $orginalSite)
                            .textInputAutocapitalization(.characters)
                    }
                }

                // Transfer Site

                HStack {

                    fieldIcon("arrow.left.arrow.right")

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Transfer Site")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField("Enter transfer site", text: $transferSite)
                            .textInputAutocapitalization(.characters)
                    }
                }

                // Bin Number

                HStack {

                    fieldIcon("shippingbox")

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Bin Number")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField("Enter bin number", text: $binno)
                            .textInputAutocapitalization(.characters)
                            .disabled(true)
                    }
                }

                // Date of Transfer

                HStack {

                    fieldIcon("calendar")

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Date of Transfer")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField("MM/DD/YYYY", text: $datetransfer)
                            .keyboardType(.numbersAndPunctuation)
                    }
                }

                // Flagging

                HStack {

                    fieldIcon("flag")

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Flagging")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField("Enter flagging", text: $flagging)
                            .textInputAutocapitalization(.words)
                            .disabled(true)
                    }
                }
            }

            // MARK: - Personnel Information

            Section("Personnel Information") {

                // Prepared By

                HStack {

                    fieldIcon("person.fill")

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Prepared By")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField("Enter Name", text: $preparedby)
                            .textInputAutocapitalization(.words)
                    }
                }

                // Verified By

                HStack {

                    fieldIcon("person.badge.shield.checkmark")

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Verified By")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField("Enter Name", text: $verifiedby)
                            .textInputAutocapitalization(.words)
                    }
                }
            }

            // MARK: - Submit Button

            Section {

                Button {

                    Task {
                        await confirmTransfer()
                    }

                } label: {

                    HStack {

                        Spacer()

                        if isSubmitting {

                            ProgressView()
                                .tint(.white)

                            Text("Submitting...")

                        } else {

                            Image(systemName: "paperplane.fill")

                            Text("Submit")
                                .fontWeight(.semibold)
                        }

                        Spacer()
                    }
                    .padding(10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(isSubmitting)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Fill Information")
        .navigationBarTitleDisplayMode(.inline)
        
        // MARK: - Navigation
        
        .navigationDestination(isPresented: $goToHome) {
            WH_Dashboard()
        }

        // MARK: - Alert

        .alert("Transfer Submission", isPresented: $showAlert) {

            Button("OK", role: .cancel) { }

        } message: {

            Text(alertMessage)
        }
        .onAppear() {
            getBatchInfo(lotnumber: lotnumber, sessionid: sessionID)
        }
    }

    // MARK: - Field Icon

    @ViewBuilder
    private func fieldIcon(_ systemName: String) -> some View {

        ZStack {

            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.15))
                .frame(width: 40, height: 40)

            Image(systemName: systemName)
                .foregroundStyle(.green)
        }
    }

    // MARK: - Confirm Transfer

    @MainActor
    private func confirmTransfer() async {

        // Validate required fields

        guard !orginalSite.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter the Original Site."
            showAlert = true
            return
        }

        guard !transferSite.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter the Transfer Site."
            showAlert = true
            return
        }

        guard !binno.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter the Bin Number."
            showAlert = true
            return
        }

        guard !datetransfer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter the Date of Transfer."
            showAlert = true
            return
        }

        guard !flagging.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter the Flagging."
            showAlert = true
            return
        }
        
        guard !preparedby.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter Prepared By."
            showAlert = true
            return
        }
        
        guard !verifiedby.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter Verified By."
            showAlert = true
            return
        }

        guard !sessionID.isEmpty else {
            alertMessage = "Session ID is missing."
            showAlert = true
            return
        }

        // API URL

        guard let url = URL(
            string: "https://ops.stellarseedscorp.org/App/Warehouse/confirm_transfer.php"
        ) else {
            alertMessage = "Invalid API URL."
            showAlert = true
            return
        }

        isSubmitting = true

        defer {
            isSubmitting = false
        }

        // Request

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        // Request Body

        let body: [String: Any] = [

            "sessionid": sessionID,
            "lotnumber": lotnumber,

            "original_site": orginalSite,
            "transfer_site": transferSite,
            "binno": binno,
            "datetransfer": datetransfer,
            "flagging": flagging,

            "preparedby": preparedby,
            "verifiedby": verifiedby
        ]

        do {

            request.httpBody = try JSONSerialization.data(
                withJSONObject: body
            )

            // API Request

            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let httpResponse = response as? HTTPURLResponse else {

                alertMessage = "Invalid server response."
                showAlert = true
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {

                alertMessage = "Server error: HTTP \(httpResponse.statusCode)"
                showAlert = true
                return
            }

            let result = String(
                data: data,
                encoding: .utf8
            )?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            print("Confirm Transfer Response: \(result)")

            if result == "savetag" {

                alertMessage = "Transfer successfully submitted!"
                goToHome = true
                // Add your navigation action here if needed.

            } else {

                alertMessage = result.isEmpty
                    ? "The server returned an empty response."
                    : "Submission failed: \(result)"
            }

            showAlert = true

        } catch {

            print("Confirm Transfer Error: \(error.localizedDescription)")

            alertMessage = "Unable to submit transfer. Please check your internet connection and try again."

            showAlert = true
        }
    }
    
    func getBatchInfo(lotnumber: String, sessionid: String) {

        guard let encodedLot = lotnumber.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) else { return }

        let urlString = "https://ops.stellarseedscorp.org/App/Warehouse/v2/get_batchdetails_ISM.php?lotno=\(encodedLot)&sessionid=\(sessionid)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print("Network error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(
                    [BatchDetailsForISM].self,
                    from: data
                )

                DispatchQueue.main.async {
                    print("danrs: \(result)")
                    self.batchdetailsforism = result
                    self.binno = result.first?.bin_name ?? ""
                    self.flagging = result.first?.qf ?? ""
                    self.datetransfer = result.first?.date_now ?? ""
                    self.transferSite = result.first?.wh ?? ""
                }

            } catch {
                print("Decoding error:", error)
                print(String(data: data, encoding: .utf8) ?? "")
            }

        }.resume()
    }
}

#Preview {

    NavigationStack {

        WH_Fill_Info(
            lotnumber: "SSC080011ZEUS26",
            sessionID: "1"
        )
    }
}
