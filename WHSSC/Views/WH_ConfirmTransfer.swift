import SwiftUI

struct BatchDataCN: Codable, Identifiable {
    let id: String
    let sessionid: String
    let lotnumber: String
    let rhid: String
    let date_created: String
    let wh: String
    let status: String
}

struct WH_ConfirmTransfer: View {

    let lotno: String
    let rhid: Int
    let processtype: String
    let jbno: String
    let kg: Double
    let tagid: Int

    @State private var batchdatacn: [BatchDataCN] = []
    @State private var openConfirmAlert = false
    @State private var goToPreviewConfirm = false

    var body: some View {
        List {
            ForEach(batchdatacn) { batch in
                Section {
                    VStack(alignment: .leading) {
                        Text("Lot Number")
                            .foregroundStyle(.secondary)

                        Text(batch.lotnumber)
                            .font(.title2)
                    }

                    VStack(alignment: .leading) {
                        Text("Current Warehouse")
                            .foregroundStyle(.secondary)

                        Text("Warehouse \(batch.wh)")
                            .font(.title2)
                    }

                }
                
                HStack {
                    Spacer()

                    Button("Cancel") {
                        // Add cancellation action here
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)

                    Button("Confirm") {
                        openConfirmAlert = true
                    }
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Confirm Transfer")
        .navigationDestination(isPresented: $goToPreviewConfirm) {
            WH_PreviewConfirm(
                lotno: lotno,
                rhid: rhid,
                processtype: processtype,
                jbno: jbno,
                kg: kg,
                tagid: tagid
            )
        }
        .alert("Confirmation", isPresented: $openConfirmAlert) {
            Button("Cancel", role: .cancel) {}

            Button("Confirm") {
                updateStatus(lotno: lotno, sessionid: batchdatacn.first?.sessionid ?? "NA")
            }
        } message: {
            Text("Please confirm to transfer this batch to another warehouse.")
        }
        .onAppear {
            getBatchInfo(lotnumber: lotno)
        }
    }

func getBatchInfo(lotnumber: String) {

    guard let encodedLot = lotnumber.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed
    ) else { return }

    let urlString = "https://ops.stellarseedscorp.org/App/Warehouse/v2/check_batch_tf.php?lotno=\(encodedLot)"

    guard let url = URL(string: urlString) else { return }

    URLSession.shared.dataTask(with: url) { data, response, error in

        if let error = error {
            print("Network error:", error.localizedDescription)
            return
        }

        guard let data = data else { return }

        do {
            let result = try JSONDecoder().decode(
                [BatchDataCN].self,
                from: data
            )

            DispatchQueue.main.async {
                self.batchdatacn = result
            }

        } catch {
            print("Decoding error:", error)
            print(String(data: data, encoding: .utf8) ?? "")
        }

    }.resume()
}

func updateStatus(lotno: String, sessionid: String) {

    guard let encodedLot = lotno.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed
    ) else { return }

    let urlString = "https://ops.stellarseedscorp.org/App/Warehouse/v2/update_status.php?lotno=\(encodedLot)&sessionid=\(sessionid)"

    guard let url = URL(string: urlString) else { return }

    URLSession.shared.dataTask(with: url) { data, response, error in

        if let error = error {
            print("Network error:", error.localizedDescription)
            return
        }

        guard let data = data else { return }

        let result = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        DispatchQueue.main.async {

            if result == "Updated" {
                goToPreviewConfirm = true
            } else {
                print("Update failed:", result ?? "No response")
            }
        }

    }.resume()
}

}

#Preview {
    WH_ConfirmTransfer(
        lotno: "DAN2026TUES0934",
        rhid: 0,
        processtype: "",
        jbno: "",
        kg: 0,
        tagid: 0
    )
}
