//
//  ContentView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 06.08.2024.
//

import Foundation
import SwiftUI

struct TopView: View {
    var body: some View {
        HStack (alignment: .top, content: {
            Text("Health Data Visualizer")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        })
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.8))
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            TopView()
            TabView {
                FetchDataView()
                    .tabItem() {
                        Label("Your Data", systemImage: "person.crop.circle")
                    }
                ChartsView()
                    .tabItem() {
                        Label("Charts", systemImage: "list.dash")
                    }
            }
        }
    }
}
