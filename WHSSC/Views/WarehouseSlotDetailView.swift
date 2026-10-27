//
//  WarehouseSlotDetailView.swift
//  WHSSC
//
//  Created by Dan on 10/27/26.
//

import SwiftUI

struct JumboBag: Identifiable {
    let id: Int
    let bagNumber: String
    let batch: String
    let weight: Double
}

struct WarehouseSlotDetailView: View {
    let slotName: String
    let bags: [JumboBag]

    @State private var selectedBag: JumboBag?

    private let maxBags = 3

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Warehouse Slot")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(slotName)
                            .font(.largeTitle.bold())
                    }

                    Spacer()

                    Text(bags.count == maxBags ? "FULL" : "AVAILABLE")
                        .font(.caption.bold())
                        .foregroundStyle(bags.count == maxBags ? .red : .green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            (bags.count == maxBags ? Color.red : Color.green)
                                .opacity(0.12)
                        )
                        .clipShape(Capsule())
                }

                VStack(spacing: 8) {
                    Text("JUMBO BAG STACK")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.07))
                            .frame(height: 290)

                        VStack(spacing: 0) {
                            ForEach(Array(bags.enumerated().reversed()), id: \.element.id) { index, bag in
                                Button {
                                    selectedBag = bag
                                } label: {
                                    JumboBag3D(
                                        bagNumber: bag.bagNumber,
                                        batch: bag.batch,
                                        weight: bag.weight,
                                        level: index + 1
                                    )
                                }
                                .buttonStyle(.plain)
                                .zIndex(Double(index))
                            }
                        }
                        .padding(.bottom, 20)
                    }

                    Text("\(bags.count)/\(maxBags) positions occupied")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Stored Jumbo Bags")
                        .font(.headline)

                    ForEach(Array(bags.enumerated()), id: \.element.id) { index, bag in
                        Button {
                            selectedBag = bag
                        } label: {
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                                    .frame(width: 36, height: 36)
                                    .background(.green.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(bag.bagNumber)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.primary)

                                    Text("Batch: \(bag.batch)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text("\(bag.weight, specifier: "%.2f") kg")
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundStyle(.primary)
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("Tap a bag to view its details.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(slotName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedBag) { bag in
            NavigationStack {
                Form {
                    LabeledContent("Bag Number", value: bag.bagNumber)
                    LabeledContent("Batch", value: bag.batch)
                    LabeledContent("Weight", value: "\(bag.weight.formatted(.number.precision(.fractionLength(2)))) kg")
                }
                .navigationTitle("Jumbo Bag Details")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
    }
}

struct JumboBag3D: View {
    let bagNumber: String
    let batch: String
    let weight: Double
    let level: Int

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 5) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 27))
                Text("LEVEL \(level)")
                    .font(.system(size: 9, weight: .bold))
                Text(bagNumber)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 155, height: 66)
            .background(
                LinearGradient(
                    colors: [.green.opacity(0.85), .green],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 9))

            Rectangle()
                .fill(.green.opacity(0.65))
                .frame(width: 12, height: 66)
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(.black.opacity(0.08))
                        .frame(width: 2)
                }
        }
        .overlay(alignment: .bottom) {
            Text("\(batch) • \(weight.formatted(.number.precision(.fractionLength(0)))) kg")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white)
                .padding(.bottom, 4)
        }
        .frame(width: 167, height: 66)
    }
}

#Preview {
    NavigationStack {
        WarehouseSlotDetailView(
            slotName: "A-1",
            bags: [
                JumboBag(id: 1, bagNumber: "JB-001", batch: "BATCH-A", weight: 1543),
                JumboBag(id: 2, bagNumber: "JB-002", batch: "BATCH-A", weight: 1000),
                JumboBag(id: 3, bagNumber: "JB-003", batch: "BATCH-B", weight: 1000)
            ]
        )
    }
}
