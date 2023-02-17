//
//  ContentView.swift
//  Example_SwiftUI
//
//  Created by Colin Walsh on 2/17/23.
//

import SwiftUI
import CoverSheet

struct ContentView: View {
    @EnvironmentObject
    var sheetManager: DefaultSheetManager
    
    var body: some View {
        CoverSheetView(sheetManager) {
            VStack {
                HStack {
                    Spacer()
                    switch sheetManager.sheetState {
                    case .minimized:
                        Text("Minimized")
                    case .normal:
                        Text("Normal")
                    default:
                        Text("Full")
                    }
                    Spacer()
                }.padding(.top, 50)
                Spacer()
            }
        } sheet: { height in
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        switch sheetManager.sheetState {
                        case .minimized:
                            Text("Minimized")
                        case .normal:
                            Text("Normal")
                        default:
                            Text("Full")
                        }
                        Spacer()
                    }
                }
                .animation(.default, value: sheetManager.sheetState)
                .frame(height: height)
            }
            .disabled(true)
            .background(Color.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
