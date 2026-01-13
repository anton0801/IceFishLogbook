import Foundation
import FirebaseDatabase
import FirebaseAuth
import Combine

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private var ref: DatabaseReference
    private var userId: String?
    private var sessionObserver: DatabaseHandle?
    
    @Published var isAuthenticated = false
    @Published var sessions: [FishingSession] = []
    
    private init() {
        ref = Database.database().reference()
        if Auth.auth().currentUser?.uid == nil {
            authenticateAnonymously()
        } else {
            userId = Auth.auth().currentUser?.uid
        }
        
        observeSessions()
    }
    
    // MARK: - Authentication
    func authenticateAnonymously() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Anonymous auth failed: \(error.localizedDescription)")
                return
            }
            
            if let user = result?.user {
                self.userId = user.uid
                self.isAuthenticated = true
                self.observeSessions()
                print("Anonymous auth successful: \(user.uid)")
            }
        }
    }
    
    // MARK: - Session Operations
    func saveSession(_ session: FishingSession, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let sessionRef = ref.child("users").child(userId).child("sessions").child(session.id)
        
        sessionRef.setValue(session.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateSession(_ session: FishingSession, completion: @escaping (Result<Void, Error>) -> Void) {
        var updatedSession = session
        updatedSession.updatedAt = Date()
        saveSession(updatedSession, completion: completion)
    }
    
    func deleteSession(_ sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let sessionRef = ref.child("users").child(userId).child("sessions").child(sessionId)
        
        sessionRef.removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchSessions(completion: @escaping (Result<[FishingSession], Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let sessionsRef = ref.child("users").child(userId).child("sessions")
        
        sessionsRef.observeSingleEvent(of: .value) { snapshot in
            var sessions: [FishingSession] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let session = FishingSession.fromSnapshot(childSnapshot) {
                    sessions.append(session)
                }
            }
            
            completion(.success(sessions.sorted { $0.date > $1.date }))
        }
    }
    
    // MARK: - Real-time Observation
    func observeSessions() {
        guard let userId = userId else { return }
        
        let sessionsRef = ref.child("users").child(userId).child("sessions")
        
        sessionObserver = sessionsRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            var sessions: [FishingSession] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let session = FishingSession.fromSnapshot(childSnapshot) {
                    sessions.append(session)
                }
            }
            
            DispatchQueue.main.async {
                self.sessions = sessions.sorted { $0.date > $1.date }
            }
        }
    }
    
    func stopObserving() {
        if let observer = sessionObserver, let userId = userId {
            let sessionsRef = ref.child("users").child(userId).child("sessions")
            sessionsRef.removeObserver(withHandle: observer)
            sessionObserver = nil
        }
    }
    
    // MARK: - Data Reset
    func resetAllData(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let userRef = ref.child("users").child(userId)
        
        userRef.removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    deinit {
        stopObserving()
    }
}
