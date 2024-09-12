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
        Text(study.contactPoint)
        Text(study.description)
        Text(study.name)
    }
}
