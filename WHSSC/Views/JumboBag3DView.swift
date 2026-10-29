
import SwiftUI
import RealityKit
import UIKit
import simd

struct JumboBags: Codable, Identifiable {
    let assignmentID: String
    let warehouseID: String
    let elementID: String
    let sessionID: String
    let bagNumber: String
    let batch: String
    let stackLevel: String
    let weight: String
    let status: String
    let assignedAt: String
    let removedAt: String?

    var id: String { assignmentID }
    var level: Int { Int(stackLevel) ?? 0 }
    var weightValue: Double { Double(weight) ?? 0 }

    enum CodingKeys: String, CodingKey {
        case assignmentID = "assignment_id"
        case warehouseID = "warehouse_id"
        case elementID = "element_id"
        case sessionID = "session_id"
        case bagNumber = "jbno"
        case batch = "batch_no"
        case stackLevel = "stack_level"
        case weight = "quantity_kg"
        case status
        case assignedAt = "assigned_at"
        case removedAt = "removed_at"
    }
}

struct WHSavePositionResponse: Decodable {
    let success: Bool
    let message: String
}

struct JumboBag3DView: View {
    let elementID: String
    let tagid: String
    let sessionid: String

    @State private var bags: [JumboBags] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var rotationAngle: Float = 0
    @State private var dragStartAngle: Float = 0
    @State private var openAlertConfirmAssign = false
    @State private var selectedLevel: Int = 1
    @State private var showResultAlert = false
    @State private var resultMessage = ""
    @State private var assignmentSucceeded = false
    @State private var gobacktotags = false

    private let bagWidth: Float = 0.82
    private let bagHeight: Float = 0.90
    private let bagDepth: Float = 0.72
    private let maxStack = 3

    private var visibleBags: [JumboBags] {
        Array(
            bags.filter {
                $0.status.lowercased() == "stored" && $0.removedAt == nil
            }
            .sorted { $0.level < $1.level }
            .prefix(maxStack)
        )
    }

    private var totalWeight: Double {
        visibleBags.reduce(0) { $0 + $1.weightValue }
    }

    private var isFull: Bool {
        (1...maxStack).allSatisfy { level in
            visibleBags.contains { $0.level == level }
        }
    }

    private func positionName(for level: Int) -> String {
        switch level {
        case 1: return "Bottom"
        case 2: return "Middle"
        case 3: return "Top"
        default: return "Unknown"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("JUMBO BAG STACK")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)

                        Text("\(visibleBags.count)/\(maxStack) Bags")
                            .font(.title2.bold())
                    }

                    Spacer()

                    Text(isFull ? "FULL" : "AVAILABLE")
                        .font(.caption.bold())
                        .foregroundStyle(isFull ? .red : .green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background((isFull ? Color.red : Color.green).opacity(0.12))
                        .clipShape(Capsule())
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TOTAL WEIGHT")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(totalWeight.formatted(.number.precision(.fractionLength(2)))) kg")
                            .font(.title3.bold())
                    }

                    Spacer()

                    Text("Slot ID: \(elementID)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                if isLoading {
                    ProgressView("Loading jumbo bags...")
                        .frame(maxWidth: .infinity, minHeight: 100)
                } else if let errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)

                        Text(errorMessage)
                            .font(.caption)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task {
                                await fetchBags()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, minHeight: 140)
                } else {
                    RealityView { content in
                        let root = Entity()
                        root.name = "jumboStack"
                        content.add(root)

                        let camera = PerspectiveCamera()
                        camera.name = "jumboCamera"
                        camera.position = [
                            2.2,
                            max(1.8, Float(maxStack) * 0.75),
                            3.2
                        ]
                        camera.look(
                            at: [0, Float(maxStack) * bagHeight / 2, 0],
                            from: camera.position,
                            relativeTo: nil
                        )
                        content.add(camera)

                        let light = DirectionalLight()
                        light.light.intensity = 1800
                        light.position = [2, 4, 3]
                        light.look(
                            at: [0, 0.8, 0],
                            from: light.position,
                            relativeTo: nil
                        )
                        content.add(light)
                    } update: { content in
                        guard let root = content.entities.first(where: {
                            $0.name == "jumboStack"
                        }) else {
                            return
                        }

                        root.transform.rotation = simd_quatf(
                            angle: rotationAngle,
                            axis: [0, 1, 0]
                        )

                        root.children.removeAll()

                        let concrete = SimpleMaterial(
                            color: UIColor(
                                red: 0.48,
                                green: 0.48,
                                blue: 0.46,
                                alpha: 1
                            ),
                            roughness: 1.0,
                            isMetallic: false
                        )

                        let floor = ModelEntity(
                            mesh: .generateBox(size: [2.6, 0.08, 2.2]),
                            materials: [concrete]
                        )
                        floor.position.y = -0.045
                        root.addChild(floor)

                        for bag in visibleBags {
                            let bagEntity = createBag(bag: bag)
                            bagEntity.position.y =
                                bagHeight / 2 + Float(bag.level - 1) * bagHeight
                            root.addChild(bagEntity)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                rotationAngle = dragStartAngle + Float(value.translation.width) * 0.01
                            }
                            .onEnded { _ in
                                dragStartAngle = rotationAngle
                            }
                    )
                    .frame(height: 380)
                    .background(Color.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    HStack(spacing: 6) {
                        Image(systemName: "hand.draw")
                        Text("Drag to rotate the 3D stack")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Stored Bags")
                            .font(.headline)

                        if visibleBags.isEmpty {
                            Text("No stored bags in this slot.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 12)
                        }

                        ForEach(1...maxStack, id: \.self) { level in
                            let bag = visibleBags.first { $0.level == level }
                            let position = positionName(for: level)

                            HStack(spacing: 12) {
                                Text("\(level)")
                                    .font(.headline)
                                    .foregroundStyle(bag == nil ? .gray : .green)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        bag == nil
                                            ? Color.gray.opacity(0.12)
                                            : Color.green.opacity(0.12)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 4) {
                                    if let bag {
                                        Text(bag.bagNumber)
                                            .font(.subheadline.bold())

                                        Text("Batch: \(bag.batch)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("Available Slot")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.green)

                                        Text(position)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                if let bag {
                                    VStack(alignment: .trailing) {
                                        Text("\(bag.weightValue.formatted(.number.precision(.fractionLength(2)))) kg")
                                            .font(.subheadline.monospacedDigit())

                                        Text(position)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Button {
                                        selectedLevel = level
                                        openAlertConfirmAssign = true
                                    } label: {
                                        Image(systemName: "plus.circle")
                                            .font(.title2)
                                            .foregroundStyle(.green)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isSaving || isFull)
                                }
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tag ID: \(tagid)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("Session ID: \(sessionid)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.regularMaterial)
        }
        .navigationTitle("Jumbo Assignment")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $gobacktotags) {
             WH_Tags(lotno: bags.first?.batch ?? "NA")
        }
        .confirmationDialog(
            "Confirm Assignment",
            isPresented: $openAlertConfirmAssign,
            titleVisibility: .visible
        ) {
            Button("Confirm") {
                Task {
                    await assignSlot(
                        sessionid: sessionid,
                        tagid: tagid,
                        element_id: elementID,
                        level: selectedLevel
                    )
                }
            }
            .disabled(isSaving)

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Assign jumbo bag to \(positionName(for: selectedLevel)) (Level \(selectedLevel))?")
        }
        .alert("Assignment Result", isPresented: $showResultAlert) {
            Button("OK", role: .cancel) {
                if assignmentSucceeded {
                    gobacktotags = true
                }
                
                gobacktotags = true
            }
        } message: {
//            Text(resultMessage)
        }
        .task {
            await fetchBags()
        }
        .refreshable {
            await fetchBags()
        }
    }

    // MARK: - Save Selected Position

    @MainActor
    private func assignSlot(sessionid: String, tagid: String, element_id: String, level: Int) async {
        guard !isSaving else { return }

        guard (1...maxStack).contains(level) else {
            resultMessage = "Invalid stack level."
            assignmentSucceeded = false
            showResultAlert = true
            return
        }

        guard let url = URL(string: "https://ops.stellarseedscorp.org/REST/whsaveposition") else {
            resultMessage = "Invalid API URL."
            assignmentSucceeded = false
            showResultAlert = true
            return
        }

        isSaving = true
        defer { isSaving = false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let parameters: [String: Any] = [
            "sessionid": sessionid,
            "tagid": tagid,
            "element_id": element_id,
            "level": level
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            let responseText = String(data: data, encoding: .utf8) ?? "No response body"

            print("========== SAVE POSITION ==========")
            print("Session ID:", sessionid)
            print("Tag ID:", tagid)
            print("Element ID:", element_id)
            print("Selected Level:", level)
            print("HTTP Status:", httpResponse.statusCode)
            print("POST Response:", responseText)
            print("===================================")

            guard (200...299).contains(httpResponse.statusCode) else {
                resultMessage = "Server error (\(httpResponse.statusCode))."
                assignmentSucceeded = false
                showResultAlert = true
                return
            }

            if let result = try? JSONDecoder().decode(WHSavePositionResponse.self, from: data) {
                guard result.success else {
                    resultMessage = result.message
                    assignmentSucceeded = false
                    showResultAlert = true
                    return
                }

                await fetchBags()
                gobacktotags = true
                return
            }

            // If the response is invalid JSON, verify the saved assignment.
            await fetchBags()

            let assignmentExists = bags.contains {
                $0.sessionID.caseInsensitiveCompare(sessionid) == .orderedSame &&
                $0.elementID == element_id &&
                $0.level == level &&
                $0.status.lowercased() == "stored" &&
                $0.removedAt == nil
            }

            if assignmentExists {
                gobacktotags = true
            } else {
                resultMessage = "The server response is invalid. Please refresh and verify the assignment."
                assignmentSucceeded = false
                showResultAlert = true
            }

        } catch {
            resultMessage = "Unable to save position: \(error.localizedDescription)"
            assignmentSucceeded = false
            showResultAlert = true
            print("Save Position Error:", error)
        }
    }

    // MARK: - Fetch Bags

    @MainActor
    private func fetchBags() async {
        guard let url = URL(
            string: "https://ops.stellarseedscorp.org/REST/whspappid/\(elementID)"
        ) else {
            errorMessage = "Invalid API URL."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 20

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "Unable to load bags. Please try again."
                return
            }

            let decodedBags = try JSONDecoder().decode([JumboBags].self, from: data)

            bags = decodedBags.sorted { $0.level < $1.level }

        } catch {
            errorMessage = "Failed to load bags: \(error.localizedDescription)"
            print("JumboBag API Error:", error)
        }
    }

    // MARK: - Create 3D Jumbo Bag

    private func createBag(bag: JumboBags) -> Entity {
        let root = Entity()

        let fabric = SimpleMaterial(
            color: UIColor(red: 0.91, green: 0.89, blue: 0.82, alpha: 1),
            roughness: 0.98,
            isMetallic: false
        )

        let body = ModelEntity(
            mesh: .generateBox(
                size: [bagWidth, bagHeight * 0.92, bagDepth],
                cornerRadius: 0.045
            ),
            materials: [fabric]
        )
        root.addChild(body)

        let top = ModelEntity(
            mesh: .generateBox(
                size: [bagWidth * 0.94, 0.035, bagDepth * 0.94],
                cornerRadius: 0.025
            ),
            materials: [fabric]
        )
        top.position.y = bagHeight * 0.46
        root.addChild(top)

        let textMesh = MeshResource.generateText(
            bag.bagNumber,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.11, weight: .heavy),
            containerFrame: CGRect(
                x: 0,
                y: 0,
                width: CGFloat(bagWidth * 0.80),
                height: CGFloat(bagHeight * 0.25)
            ),
            alignment: .center,
            lineBreakMode: .byClipping
        )

        let printedText = ModelEntity(
            mesh: textMesh,
            materials: [
                SimpleMaterial(color: .black, roughness: 1, isMetallic: false)
            ]
        )

        printedText.position = [
            -bagWidth * 0.40,
            -bagHeight * 0.10,
            bagDepth / 2 + 0.005
        ]

        root.addChild(printedText)
        return root
    }
}

#Preview {
    NavigationStack {
        JumboBag3DView(
            elementID: "3504",
            tagid: "22",
            sessionid: "14F8B428-EA6C-4DD3-B30E-3507E6F898C5"
        )
    }
}
