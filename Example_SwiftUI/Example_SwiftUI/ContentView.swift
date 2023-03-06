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
    
    @State
    var enableBlur: Bool = false
    
    @State
    var backgroundColor: Color = .white
    
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
        }
        .sheetBackgroundColor(backgroundColor)
        .enableBlurEffect(enableBlur)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                enableBlur.toggle()
                backgroundColor = .clear
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
