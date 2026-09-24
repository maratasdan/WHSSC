//
//  ContentView.swift
//  WHSSC
//
//  Created by Dan on 9/23/26.
//

import SwiftUI

struct ContentView: View {

    // MARK: - Sheet

    @State private var sheetforqr = false
    
    //MARK: Navigations
    @State private var goToWh: Bool = false
    @State private var goTo_ISM_List: Bool = false
    
    //MARK: Assignments
    @State private var wh: String = ""

    var body: some View {

        NavigationStack {

            ScrollView(.vertical, showsIndicators: true) {

                VStack(alignment: .leading) {

                    HStack {
                        Text("WAREHOUSE")
                            .font(.title)
                            .bold()

                        Spacer()
                    }

                    VStack {

                        ZStack {

                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color.green)

                            HStack {

                                ZStack {

                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.50))
                                        .frame(width: 60, height: 60)

                                    Image(systemName: "qrcode")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading) {

                                    Text("QR Scanner")
                                        .foregroundStyle(.white)

                                    Text("Scan")
                                        .foregroundStyle(.white)
                                        .font(.title)
                                        .bold()
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 20)
                                    .foregroundStyle(.white)
                            }
                            .padding(15)
                        }
                        .onTapGesture {
                            sheetforqr = true
                        }
                        
                        //MARK: Warehouses
                        VStack(alignment: .leading) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    VStack {
                                        ZStack {
                                            Rectangle()
                                                .frame(width: 200, height: 200)
                                                .cornerRadius(20)
                                                .foregroundStyle(Color.green.opacity(0.30))
                                            HStack {
                                                Image(systemName: "shippingbox.fill")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundStyle(Color.green)
                                                VStack {
                                                    Text("WH 1")
                                                        .bold()
                                                }
                                            }
                                        }
                                    }
                                    .onTapGesture {
                                        wh = "1"
                                        goToWh = true
                                    }
                                    
                                    VStack {
                                        ZStack {
                                            Rectangle()
                                                .frame(width: 200, height: 200)
                                                .cornerRadius(20)
                                                .foregroundStyle(Color.green.opacity(0.30))
                                            HStack {
                                                Image(systemName: "shippingbox.fill")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundStyle(Color.green)
                                                VStack {
                                                    Text("WH 2")
                                                        .bold()
                                                }
                                            }
                                        }
                                    }
                                    .onTapGesture {
                                        wh = "2"
                                        goToWh = true
                                    }
                                    
                                    VStack {
                                        ZStack {
                                            Rectangle()
                                                .frame(width: 200, height: 200)
                                                .cornerRadius(20)
                                                .foregroundStyle(Color.green.opacity(0.30))
                                            HStack {
                                                Image(systemName: "shippingbox.fill")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundStyle(Color.green)
                                                VStack {
                                                    Text("WH 3")
                                                        .bold()
                                                }
                                            }
                                        }
                                    }
                                    .onTapGesture {
                                        wh = "3"
                                        goToWh = true
                                    }
                                    
                                    VStack {
                                        ZStack {
                                            Rectangle()
                                                .frame(width: 200, height: 200)
                                                .cornerRadius(20)
                                                .foregroundStyle(Color.green.opacity(0.30))
                                            HStack {
                                                Image(systemName: "shippingbox.fill")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundStyle(Color.green)
                                                VStack {
                                                    Text("WH 4")
                                                        .bold()
                                                }
                                            }
                                        }
                                    }
                                    .onTapGesture {
                                        wh = "4"
                                        goToWh = true
                                    }
                                }
                            }
                        }
                        .padding(.top, 15)
                        
                        //MARK: Quick Actions
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Quick Actions")
                                    .font(.title2)
                                Spacer()
                            }
                            
//                            //MARK: Operate Batches
//                            ZStack {
//                                Rectangle()
//                                    .foregroundStyle(Color.orange)
//                                    .frame(height: 60)
//                                    .cornerRadius(16)
//                                HStack {
//                                    ZStack {
//                                        Rectangle()
//                                            .frame(width: 40, height: 40)
//                                            .cornerRadius(12)
//                                            .foregroundStyle(Color.white.opacity(0.50))
//                                        Image(systemName: "gearshape.fill")
//                                            .symbolEffect(.rotate.byLayer, options: .repeat(.periodic(delay: 1.0)))
//                                            .foregroundStyle(Color.white)
//                                    }
//                                    VStack(alignment: .leading) {
//                                        Text("Operate Batches")
//                                            .foregroundStyle(Color.white)
//                                            .bold()
//                                        Text("Configure for Processing")
//                                            .font(.footnote)
//                                            .foregroundStyle(Color.white)
//                                    }
//                                    Spacer()
//                                    Image(systemName: "chevron.right")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 10, height: 20)
//                                        .foregroundStyle(.white)
//                                }
//                                .padding(10)
//                            }
//                            
//                            //MARK: Create ISM
//                            ZStack {
//                                Rectangle()
//                                    .foregroundStyle(Color.blue)
//                                    .frame(height: 60)
//                                    .cornerRadius(16)
//                                HStack {
//                                    ZStack {
//                                        Rectangle()
//                                            .frame(width: 40, height: 40)
//                                            .cornerRadius(12)
//                                            .foregroundStyle(Color.white.opacity(0.50))
//                                        Image(systemName: "list.bullet.rectangle.portrait")
//                                            .foregroundStyle(Color.white)
//                                    }
//                                    VStack(alignment: .leading) {
//                                        Text("Create ISM")
//                                            .foregroundStyle(Color.white)
//                                            .bold()
//                                        Text("Inventory Stock Movement")
//                                            .font(.footnote)
//                                            .foregroundStyle(Color.white)
//                                    }
//                                    Spacer()
//                                    Image(systemName: "chevron.right")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 10, height: 20)
//                                        .foregroundStyle(.white)
//                                }
//                                .padding(10)
//                            }
                            
                            //MARK: View ISM List
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color.secondary)
                                    .frame(height: 60)
                                    .cornerRadius(16)
                                HStack {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(12)
                                            .foregroundStyle(Color.white.opacity(0.50))
                                        Image(systemName: "list.number")
                                            .foregroundStyle(Color.white)
                                    }
                                    VStack(alignment: .leading) {
                                        Text("View ISM List")
                                            .foregroundStyle(Color.white)
                                            .bold()
                                        Text("List of Created ISM")
                                            .font(.footnote)
                                            .foregroundStyle(Color.white)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10, height: 20)
                                        .foregroundStyle(.white)
                                }
                                .padding(10)
                            }
                            .onTapGesture {
                                goTo_ISM_List = true
                            }
                            
                        }
                        .padding(.top, 15)
                        
                    }
                    .padding(.top, 10)
                }
                //MARK: Navigations
                .navigationDestination(isPresented: $goToWh) {
                    WarehouseList(wh: wh)
                }
                .navigationDestination(isPresented: $goTo_ISM_List) {
                    ISM_List()
                }
            }
            .padding(20)
            .navigationTitle("Warehouse")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: - QR Scanner Sheet

            .sheet(isPresented: $sheetforqr) {
                NavigationStack {
                    QRScanner()
                        .onReceive(
                            NotificationCenter.default.publisher(
                                for: Notification.Name("CloseEntireSheet")
                            )
                        ) { _ in
                            sheetforqr = false
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
