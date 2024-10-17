//
//  ParticipantStudyView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 06.10.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import HealthKit
import Foundation

struct ParticipantStudyView: View {
    var study: Study
    @EnvironmentObject var healthDataModel: HealthDataModel
    @State private var isEnrolledInStudy: Bool? = nil
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Top container with image and close button
                ZStack(alignment: .topLeading) {
                    Color.blue.opacity(0.3).edgesIgnoringSafeArea(.top)
                    
                    VStack {
                        Image("SampleStudyIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 400, height: 400)
                            .padding(.top, 40)
                        
                        Spacer()
                    }
                }
                .frame(height: 300)
                
                // Product detail section
                VStack(alignment: .leading, spacing: 12) {
                    Text(study.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(study.contactPoint)
                        .foregroundColor(.gray)
                    
                    // About product section
                    Text("Description")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    Text(study.description)
                        .foregroundColor(.gray)
                        .font(.body)
                    
                    Text("Start Date of Requested Data")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    Text("\(study.startDate, formatter: dateFormatter)")
                        .foregroundColor(.gray)
                        .font(.body)
                    
                    Spacer()
                    
                    if let isEnrolled = isEnrolledInStudy {
                        if isEnrolled {
                            Text("You are currently enrolled in this study.")
                                .foregroundColor(Color.green.opacity(0.6))
                                .font(.headline)
                                .padding(.top)
                                .frame(maxWidth: .infinity)
                        } else {
                            Button(action: {
                                enrollInStudy()
                            }) {
                                Text("Enroll in Study")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(20)
                            }
                            .padding(.vertical)
                        }
                    } else {
                        // Optional: Show a loading view while checking enrollment status
                        ProgressView("Checking enrollment...")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .offset(y: -30)
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                checkEnrollment()
            }
        }
    }
    
    func checkEnrollment() {
        isEnrolled { exists, error in
            if let error = error {
                print("Error fetching study from user's enrolled studies: \(error.localizedDescription)")
                isEnrolledInStudy = false // Handle the error case
            } else {
                isEnrolledInStudy = exists
            }
        }
    }
    
    func isEnrolled(completion: @escaping (Bool, Error?) -> Void) {
        guard let user = UserSessionManager.shared.currentUser else {
            print("No user is signed in")
            return
        }
        
        let db = Firestore.firestore()
        let userID = user.uid
        let userDocRef = db.collection("users").document(userID)

        // Fetch the user's document
        userDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                completion(false, nil)
                return
            }
            
            // Retrieve the list from the document
            if let data = document.data(), let someList = data["enrolledStudies"] as? [String] {
                // Check if the list contains the value
                let exists = someList.contains(study.id)
                completion(exists, nil)
            } else {
                print("enrolledStudies does not exist or is not an array")
                completion(false, nil)
            }
        }
    }
    
    func enrollInStudy() {
        guard let user = UserSessionManager.shared.currentUser else {
            print("No user is signed in")
            return
        }
        
        let db = Firestore.firestore()
        let userID = user.uid
        
        db.collection("users").document(userID).updateData([
            "enrolledStudies": FieldValue.arrayUnion([study.id])
            ]) { error in
                if let error = error {
                    print("Failed to update enrolled studies: \(error.localizedDescription)")
                    return
                }
                print("Successfully updated array \"enrolled studies.\"")
            }
        
        let typeRequested = HKQuantityTypeIdentifier.distanceWalkingRunning
        fetchRequestedHealthData(type: typeRequested, startDate: study.startDate) { statistics in
            if let statistics = statistics {
                print("Fetched statistics: \(statistics)")
                self.postStatisticsToFirestore(statistics: statistics, study: study)
            } else {
                print("Error: No statistics fetched")
            }
        }
    }
    
    func fetchRequestedHealthData(type: HKQuantityTypeIdentifier, startDate: Date, completion: @escaping ([HKStatistics]?) -> Void) {
        healthDataModel.requestHealthKitAccess()
        
        if let quantityType = HKQuantityType.quantityType(forIdentifier: type) {
            healthDataModel.fetchWeeklyData(for: quantityType, startDate: startDate) { statistics, error in
                if let error = error {
                    print("Error fetching weekly data: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(statistics)
                }
            }
        } else {
            print("Error: Invalid HealthKit quantity type identifier.")
            completion(nil)
        }
    }
    
    func postStatisticsToFirestore(statistics: [HKStatistics], study: Study) {
        let participantID = UserSessionManager.shared.currentUser?.uid ?? "Unknown User ID"
        // Define the base URL for Firestore
        let baseRequestURL = "https://firestore.googleapis.com/v1/projects/\(study.firebaseProjectID)/databases/(default)/documents"
            
        // Loop through the statistics and post each day's data
        for stat in statistics {
            guard let distance = stat.sumQuantity()?.doubleValue(for: HKUnit.meter()) else {
                continue // Skip if there's no distance
            }

            let requestURL = "\(baseRequestURL)/participants/\(participantID)/runningDistance?key=\(study.firebaseAPI)"
            
            // Ensure URL is valid
            guard let url = URL(string: requestURL) else {
                print("Invalid request URL: \(requestURL)")
                continue
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // Prepare the data to be sent to Firestore
            let firestoreData: [String: Any] = [
                "fields": [
                    "date": ["stringValue": "\(stat.startDate)"],
                    "distanceWalked": ["integerValue": "\(Int(distance))"]
                ]
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: firestoreData)

            // Perform the POST request for each data point
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error posting data to Firestore: \(error.localizedDescription)")
                    return
                }
                
                if let data = data {
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                }
            }
            
            task.resume()
        }
    }
}
