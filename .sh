#!/bin/bash

# Define environment variables for the Firebase project
FIREBASE_PROJECT_ID="sokoni-44ef1"
FIREBASE_API_KEY="AIzaSyDloF8BhJTvAV8LZAlEplSX42cPP_LwIsw"
FIREBASE_AUTH_DOMAIN="${FIREBASE_PROJECT_ID}.firebaseapp.com"
FIREBASE_DATABASE_URL="https://${FIREBASE_PROJECT_ID}.firebaseio.com"
FIREBASE_STORAGE_BUCKET="${FIREBASE_PROJECT_ID}.appspot.com"
FIREBASE_MESSAGING_SENDER_ID="353018968368"
FIREBASE_APP_ID="1:353018968368:web:aa2fe1a4d8e5f27d56f0f5"  # Replace with actual App ID
FIREBASE_MEASUREMENT_ID="G-XXXXXXXXXX"  # Replace with actual Measurement ID

# Step 1: Set Up the Development Environment
echo "Setting up the development environment..."

# Install Firebase CLI
echo "Installing Firebase CLI..."
npm install -g firebase-tools

# Step 2: Create and Configure the Firebase Project
echo "Creating Firebase project and setting up Firestore..."

# Initialize Firebase project
firebase login
firebase init

# Select Firestore and Hosting options
echo "Please follow the prompts to configure Firestore and Hosting."

# Step 3: Build and Deploy the Web App to Firebase
echo "Creating a React application for the web dashboard..."

# Create a new React app
npx create-react-app zigbee-dashboard
cd zigbee-dashboard

# Install Firebase SDK
npm install firebase

# Create Firebase configuration file
cat > src/firebase.js <<EOL
import firebase from 'firebase/app';
import 'firebase/firestore';

const firebaseConfig = {
    apiKey: "$FIREBASE_API_KEY",
    authDomain: "$FIREBASE_AUTH_DOMAIN",
    projectId: "$FIREBASE_PROJECT_ID",
    storageBucket: "$FIREBASE_STORAGE_BUCKET",
    messagingSenderId: "$FIREBASE_MESSAGING_SENDER_ID",
    appId: "$FIREBASE_APP_ID",
    measurementId: "$FIREBASE_MEASUREMENT_ID"
};

firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
export { db };
EOL

# Create React application main file
cat > src/App.js <<EOL
import React, { useState, useEffect } from 'react';
import { db } from './firebase';

function App() {
  const [devices, setDevices] = useState([]);

  useEffect(() => {
    db.collection('zigbeeDevices').onSnapshot((snapshot) => {
      setDevices(snapshot.docs.map(doc => doc.data()));
    });
  }, []);

  return (
    <div className="App">
      <h1>Zigbee Devices</h1>
      <ul>
        {devices.map((device, index) => (
          <li key={index}>{device.name}: {device.status}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
EOL

# Create .gitignore file
cat > .gitignore <<EOL
node_modules/
build/
firebase-debug.log
EOL

# Create firebase.json for Firebase Hosting configuration
cat > firebase.json <<EOL
{
  "hosting": {
    "public": "build",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
EOL

# Create .firebaserc to specify the Firebase project
cat > .firebaserc <<EOL
{
  "projects": {
    "default": "$FIREBASE_PROJECT_ID"
  }
}
EOL

# Build and deploy to Firebase Hosting
echo "Building the React application..."
npm run build

echo "Deploying to Firebase Hosting..."
firebase deploy

echo "Setup and deployment completed."
