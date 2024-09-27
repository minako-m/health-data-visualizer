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
    @State private var firebaseAPI = ""

    var clinicianId: String

    var body: some View {
        VStack {
            Text("Create a Study")
                .font(.largeTitle) // Large title
                .bold() // Bold text
                .multilineTextAlignment(.center) // Center text
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
                .foregroundColor(.white)

            Text("Study details")
                .font(.headline) // Large title
                .bold() // Bold text
                .multilineTextAlignment(.center) // Center text
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
                .foregroundColor(.white)

            TextField("Study Name", text: $studyName)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .overlay( // Adding the custom border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 1) // Light blue border
                )
                .padding(.horizontal)

            TextField("Study Description", text: $studyDescription)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .overlay( // Adding the custom border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 1) // Light blue border
                )
                .padding(.horizontal)

            TextField("Contact Point", text: $studyContactPoint)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .overlay( // Adding the custom border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 1) // Light blue border
                )
                .padding(.horizontal)

            Text("Database details")
                .font(.headline) // Large title
                .bold() // Bold text
                .multilineTextAlignment(.center) // Center text
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
                .foregroundColor(.white)

            TextField("Firebase API", text: $firebaseAPI)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .overlay( // Adding the custom border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 1) // Light blue border
                )
                .padding(.horizontal)

            Button("Save Study") {
                saveStudyToFirebase()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity) // Long rectangle
            .background(Color.blue.opacity(0.6)) // Same as the text field border
            .foregroundColor(.white) // White text color
            .cornerRadius(25) // Very rounded corners
            .padding()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.3).ignoresSafeArea())
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
