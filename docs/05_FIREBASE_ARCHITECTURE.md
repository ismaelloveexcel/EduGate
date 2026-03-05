# Firebase Architecture

Firebase Auth
Used for parent authentication

Firestore
Primary database storing:
- children
- quiz attempts
- progress
- questions

Firebase Cloud Messaging
Used to trigger quiz notifications

Firebase Analytics
Tracks engagement and gameplay metrics

Remote Config
Used to adjust quiz intervals and reward rates without redeploying the app
