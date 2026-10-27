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
}

struct WH_SetPosition: View {
    
    @State private var whslots: [WHSlots] = []
    
    var body: some View {
        NavigationStack {
            List(whslots) { itemx in
                NavigationLink(destination: JumboBag3DView(elementID: itemx.element_id)) {
                    HStack(spacing: 10) {
                        ZStack {
                            ZStack {
                                Circle()
                                    .stroke(.gray.opacity(0.2), lineWidth: 2)

                                Circle()
                                    .trim(from: 0, to: Double(itemx.slotremp))
                                    .stroke(.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                            }
                            .frame(width: 50, height: 50)
                                
                            Image(systemName: "square.stack")
                                .resizable()
                                .foregroundStyle(Color.green)
                                .frame(width: 20, height: 20)
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(itemx.label)")
                                    .bold()
                                    .font(.headline)
                                if itemx.is_full == true {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 40, height: 17)
                                            .foregroundStyle(Color.green)
                                            .cornerRadius(5)
                                        Text("FULL")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Color.white)
                                            .bold()
                                    }
                                }
                            }
                            HStack {
                                Text("Slots: \(itemx.slotrem)/\(itemx.max_bags)")
                                    .font(.footnote)
                                Text("Total Kg: \(itemx.total_kg ?? "0")")
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }
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

#Preview {
    WH_SetPosition()
}
