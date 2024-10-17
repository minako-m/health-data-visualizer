//
//  ClinicianContentView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 11.09.2024.
//

import Foundation
import SwiftUI
import FirebaseFirestore


struct ClinicianContentView: View {
    @State private var studies = [Study]()
    @State private var isShowingAddStudyView = false

    var body: some View {
        NavigationStack {
            VStack {
                if studies.isEmpty {
                    Text("No studies available")
                        .padding()
                } else {
                    List(studies) { study in
                        NavigationLink(study.name) {
                            StudyView(study: study)
                        }
                    }
                }
            }
            .navigationTitle("My Studies")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                // Sign Out Button on the right of the title
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        UserSessionManager.shared.signOut()
                    }) {
                        Text("Sign Out")
                    }
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingAddStudyView = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .padding()
                                .foregroundColor(.blue)
                                .shadow(radius: 2)
                        }
                    }
                }
                .padding(),
                alignment: .bottomTrailing
            )
            .onAppear {
                fetchStudiesForClinician()
            }
            .sheet(isPresented: $isShowingAddStudyView) {
                if let userId = UserSessionManager.shared.currentUser?.uid {
                    AddStudyView(clinicianId: userId)
                        .onDisappear {
                            fetchStudiesForClinician()
                        }
                }
            }
        }
    }

    private func fetchStudiesForClinician() {
        guard let clinicianId = UserSessionManager.shared.currentUser?.uid else {
            print("No current user found")
            return
        }

        let db = Firestore.firestore()
        db.collection("studies").whereField("clinicianId", isEqualTo: clinicianId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching studies: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                self.studies = snapshot.documents.compactMap { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let name = data["name"] as? String ?? "No Name"
                    let description = data["description"] as? String ?? "No Description"
                    let contactPoint = data["contactPoint"] as? String ?? "No Contact Point"
                    let clinicianId = data["clinicianId"] as? String ?? ""
                    let firebaseAPI = data["firebaseAPI"] as? String ?? "No Firebase API"
                    let firebaseProjectID = data["firebaseProjectID"] as? String ?? "No Firebase Project ID"
                    let startDate = data["startDate"] as? Date ?? Date()

                    return Study(id: id, name: name, description: description, contactPoint: contactPoint, clinicianId: clinicianId, firebaseAPI: firebaseAPI, firebaseProjectID: firebaseProjectID, startDate: startDate)
                }
            }
        }
    }
}
