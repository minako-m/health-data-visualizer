//
//  ParticipantStudyView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 12.09.2024.
//

import SwiftUI
import FirebaseFirestore

struct ParticipantStudyView: View {
    @State private var filterStudies: String = "all"
    @State private var allStudies = [Study]()
    @State private var enrolledStudies = [Study]()
    
    var body: some View {
        VStack {
            Picker("Which studies do you want to display?", selection: $filterStudies) {
                Text("All Studies").tag("all")
                Text("My Studies").tag("enrolled")
            }
            .pickerStyle(.segmented)
            .padding()
            
            NavigationView {
                if allStudies.isEmpty {
                    Text("No studies available")
                        .padding()
                } else if filterStudies == "all" {
                    List(allStudies) { study in
                        NavigationLink(study.name) {
                            StudyView(study: study)
                        }
                    }
                    .background(Color.white)
                    .navigationTitle("Studies")
                } else if filterStudies == "enrolled" && enrolledStudies.isEmpty {
                    Text("You are currently not enrolled in any studies.")
                        .padding()
                }
            }
            .background(Color.white)
            
            Spacer()
        }
        .background(Color.white)
        .onAppear() {
            fetchAllStudies()
        }
    }
    
    func fetchAllStudies() {
        let db = Firestore.firestore()
        db.collection("studies").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching studies: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                self.allStudies = snapshot.documents.compactMap { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let name = data["name"] as? String ?? "No Name"
                    let description = data["description"] as? String ?? "No Description"
                    let contactPoint = data["contactPoint"] as? String ?? "No Contact Point"
                    let clinicianId = data["clinicianId"] as? String ?? ""

                    return Study(id: id, name: name, description: description, contactPoint: contactPoint, clinicianId: clinicianId)
                }
            }
        }
    }
}

