//
//  OperateBatches.swift
//  WHSSC
//
//  Created by Dan on 9/24/26.
//
import SwiftUI

struct OperateBatches: View {

    @State private var selectedItems = Set<String>()

    let items = ["TAG001", "TAG002", "TAG003", "TAG004"]

    var body: some View {

        NavigationStack {

            List(items, id: \.self) { item in

                HStack {

                    Text(item)

                    Spacer()

                    Image(systemName: selectedItems.contains(item)
                          ? "checkmark.circle.fill"
                          : "circle")
                        .foregroundStyle(
                            selectedItems.contains(item) ? .blue : .gray
                        )

                }
                .contentShape(Rectangle())
                .onTapGesture {

                    if selectedItems.contains(item) {

                        selectedItems.remove(item)

                    } else {

                        selectedItems.insert(item)

                    }

                }

            }
            .navigationTitle("Select Tags")
            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Select All") {

                        if selectedItems.count == items.count {

                            selectedItems.removeAll()

                        } else {

                            selectedItems = Set(items)

                        }

                    }

                }

            }

            .safeAreaInset(edge: .bottom) {

                Button {

                    print("Selected Tags:", selectedItems)

                } label: {

                    Text("Continue (\(selectedItems.count))")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                }
                .padding()

            }

        }

    }
}

#Preview {
    OperateBatches()
}
