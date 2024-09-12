//
//  AddStudyView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 11.09.2024.
//

import SwiftUI
import FirebaseFirestore

struct Study: Identifiable {
    var id: String
    var name: String
    var description: String
    var contactPoint: String
    var clinicianId: String // Store the clinician's userId
}

struct AddStudyView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet
    @State private var studyName = ""
    @State private var studyDescription = ""
    @State private var studyContactPoint = ""
    
    var clinicianId: String
        
    var body: some View {
        VStack {
            Text("Please enter the study details:")
                .font(.largeTitle)
                .padding()
            TextField("Study Name", text: $studyName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Study Description", text: $studyDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Contact Point", text: $studyContactPoint)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save Study") {
                saveStudyToFirebase()
            }
            .padding()
        }
    }
    
    func saveStudyToFirebase() {
        let db = Firestore.firestore()
        
        // Create a new study instance
        let newStudy = Study(
            id: UUID().uuidString,
            name: studyName,
            description: studyDescription,
            contactPoint: studyContactPoint,
            clinicianId: clinicianId
        )
        
        // Prepare data to be saved in Firebase
        let studyData: [String: Any] = [
            "name": newStudy.name,
            "description": newStudy.description,
            "contactPoint": newStudy.contactPoint,
            "clinicianId": newStudy.clinicianId,
            "createdAt": Timestamp() // You can also add a creation timestamp
        ]
        
        db.collection("studies").document(newStudy.id).setData(studyData) { error in
            if let error = error {
                print("Error adding study: \(error.localizedDescription)")
            } else {
                print("Study added successfully")
                presentationMode.wrappedValue.dismiss() // Dismiss the view after saving
            }
        }
    }
}
