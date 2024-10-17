//
//  ParticipantStudyView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 12.09.2024.
//

import SwiftUI
import FirebaseFirestore

struct AllStudiesView: View {
    @State private var filterStudies: String = "all"
    @State private var allStudies = [Study]()
    @State private var enrolledStudies = [Study]()
    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                Picker("Which studies do you want to display?", selection: $filterStudies) {
                    Text("All Studies").tag("all")
                    Text("My Studies").tag("enrolled")
                }
                .pickerStyle(.segmented)
                .padding()

                if allStudies.isEmpty {
                    Text("No studies available")
                        .padding()
                } else if filterStudies == "all" {
                    List(allStudies) { study in
                        NavigationLink(study.name) {
                            ParticipantStudyView(study: study)
                        }
                    }
                    .background(Color.white)
                    .navigationTitle("Studies")
                } else if filterStudies == "enrolled" && enrolledStudies.isEmpty {
                    Text("You are currently not enrolled in any studies.")
                        .padding()
                } else {
                    List(enrolledStudies) { study in
                        NavigationLink(study.name) {
                            ParticipantStudyView(study: study)
                        }
                    }
                    .background(Color.white)
                    .navigationTitle("Studies")
                }

                Spacer()
            }
            .background(Color.white)
            .onAppear() {
                fetchAllStudies()
                fetchEnrolledStudies()
            }
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
                    let clinicianId = data["clinicianId"] as? String ?? "No clinician ID"
                    let firebaseAPI = data["firebaseAPI"] as? String ?? "No Firebase API"
                    let firebaseProjectID = data["firebaseProjectID"] as? String ?? "No Firebase Project ID"
                    
                    let startDate: Date
                    if let timestamp = data["startDate"] as? Timestamp {
                        startDate = timestamp.dateValue()
                    } else {
                        startDate = Date() // Default to current date if conversion fails
                    }

                    return Study(id: id, name: name, description: description, contactPoint: contactPoint, clinicianId: clinicianId, firebaseAPI: firebaseAPI, firebaseProjectID: firebaseProjectID, startDate: startDate)
                }
            }
        }
    }
    
    func fetchEnrolledStudies() {
        guard let user = UserSessionManager.shared.currentUser else {
            print("No user is signed in")
            return
        }
        let userID = user.uid
        
        db.collection("users").document(userID).getDocument { document, error in
           if let document = document, document.exists {
               if let studyIDs = document.get("enrolledStudies") as? [String] {
                   self.enrolledStudies.removeAll()
                   self.fetchStudyDetails(studyIDs: studyIDs)
               }
           } else {
               print("User document does not exist")
           }
       }
    }
    
    // Fetch each study's details based on its ID
    private func fetchStudyDetails(studyIDs: [String]) {
        let studyCollection = db.collection("studies")
        
        for studyID in studyIDs {
            studyCollection.document(studyID).getDocument { document, error in
                if let document = document, document.exists {
                    if let studyData = document.data() {
                        let startDate: Date
                        if let timestamp = studyData["startDate"] as? Timestamp {
                            startDate = timestamp.dateValue()
                        } else {
                            startDate = Date() // Default to current date if conversion fails
                        }
                        
                        let study = Study(
                            id: studyID,
                            name: studyData["name"] as? String ?? "Unnamed Study",
                            description: studyData["description"] as? String ?? "No description",
                            contactPoint: studyData["contactPoint"] as? String ?? "No contact point",
                            clinicianId: studyData["clinicianID"] as? String ?? "No clinian ID",
                            firebaseAPI: studyData["firebaseAPI"] as? String ?? "No Firebase API",
                            firebaseProjectID: studyData["firebaseProjectID"] as? String ?? "No project ID",
                            startDate: startDate
                        )
                        DispatchQueue.main.async {
                            self.enrolledStudies.append(study)
                        }
                    }
                } else {
                    print("Study document with ID \(studyID) does not exist")
                }
            }
        }
    }
}
