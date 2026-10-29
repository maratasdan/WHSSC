//
//  WH_SetPosition.swift
//  WHSSC
//
//  Created by Dan on 10/27/26.
//

import SwiftUI

struct WHSlots: Identifiable, Codable {
    var id: String { element_id }
    var element_id: String
    var element_key: String
    var element_type: String
    var label: String
    var max_bags: String
    var total_bags: String
    var total_kg: String?
    var slotrem: Int
    var is_full: Bool
    var slotremp: Double
    
    var bagCount: Int {
        Int(total_bags) ?? 0
    }

    var progressColor: Color {
        switch bagCount {
        case 0:
            return .green
        case 1:
            return .yellow
        case 2:
            return .orange
        default:
            return .red
        }
    }
}




struct WH_SetPosition: View {
    
    let tagid: String
    let sessionid: String
    
    @State private var whslots: [WHSlots] = []
    
    private var groupedSlots: [(letter: String, slots: [WHSlots])] {
        let grouped = Dictionary(grouping: whslots) { item in
            String(item.label.prefix(1)).uppercased()
        }

        return grouped.keys.sorted().map { letter in
            (letter: letter, slots: grouped[letter] ?? [])
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedSlots, id: \.letter) { group in
                    NavigationLink {
                        WHSlotDetails(
                            letter: group.letter,
                            slots: group.slots,
                            tagid: tagid,
                            sessionid: sessionid
                        )
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.stack.3d.up")
                                .font(.title2)
                                .foregroundStyle(.green)
                                .frame(width: 45, height: 45)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Section \(group.letter)")
                                    .font(.headline)

                                Text("\(group.slots.count) positions")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

//                            Image(systemName: "chevron.right")
//                                .font(.footnote)
//                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Warehouse Positions")
        }
        .task {
            await getWHSlots()
        }
    }
    
    func getWHSlots() async {
        guard let url = URL(string: "https://ops.stellarseedscorp.org/REST/whspapp") else {
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            whslots = try JSONDecoder().decode([WHSlots].self, from: data)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

struct WHSlotDetails: View {
    
    let letter: String
    let slots: [WHSlots]
    let tagid: String
    let sessionid: String

    var body: some View {
        List(slots) { itemx in
            NavigationLink {
                JumboBag3DView(elementID: itemx.element_id,
                               tagid: tagid,
                               sessionid: sessionid)
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .stroke(.green.opacity(0.15), lineWidth: 2)

                        Circle()
                            .trim(from: 0, to: max(0, min(1, itemx.slotremp)))
                            .stroke(itemx.progressColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }
                    .frame(width: 45, height: 45)
                    .overlay {
                        Image(systemName: "square.stack.3d.up")
                            .foregroundStyle(itemx.progressColor)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(itemx.label)
                                .font(.headline)

//                            if itemx.is_full {
//                                Text("FULL")
//                                    .font(.caption2.bold())
//                                    .foregroundStyle(.white)
//                                    .padding(.horizontal, 7)
//                                    .padding(.vertical, 3)
//                                    .background(.green)
//                                    .clipShape(RoundedRectangle(cornerRadius: 4))
//                            }
                        }

                        Text("Slots: \(itemx.slotrem)/\(itemx.max_bags)")
                            .font(.footnote)

                        Text("Total Kg: \(itemx.total_kg ?? "0")")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Section \(letter)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WH_SetPosition(tagid: "", sessionid: "")
}
