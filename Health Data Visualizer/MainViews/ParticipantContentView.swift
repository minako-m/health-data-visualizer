//
//  ContentView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 06.08.2024.
//

import Foundation
import SwiftUI
import HealthKit

struct TopView: View {
    var body: some View {
        HStack (alignment: .top, content: {
            Text("Wearipedia")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        })
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.3))
    }
}

struct ParticipantContentView: View {
    var body: some View {
        VStack {
            TopView()
            TabView {
                FetchDataView()
                    .tabItem() {
                        Label("Your Data", systemImage: "person.crop.circle")
                    }
                ChartsView(dataType: .activeEnergyBurned, unit: HKUnit.kilocalorie(), title: "Active Energy Burned")
                    .tabItem() {
                        Label("Charts", systemImage: "list.dash")
                    }
                ParticipantStudyView()
                    .tabItem() {
                        Label("Studies", systemImage: "waveform.path.ecg")
                    }
            }
        }
    }
}
