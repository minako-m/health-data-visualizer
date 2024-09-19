//
//  StudyView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 12.09.2024.
//

import SwiftUI

struct StudyView: View {
    var study: Study
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(study.name)
                    .font(.largeTitle)
                    .bold()
                    .padding([.top, .horizontal])
                    .foregroundColor(.white)
                
                Text("Study Description")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                Text(study.description)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                Text("Study Contact Point")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                Text(study.contactPoint)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.3).ignoresSafeArea())
    }
}
