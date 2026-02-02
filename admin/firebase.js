// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAiY2mmTtIGzWTOOflXJgBoQPTjZs9GfY0",
  authDomain: "vybgo-c2ee0.firebaseapp.com",
  projectId: "vybgo-c2ee0",
  storageBucket: "vybgo-c2ee0.firebasestorage.app",
  messagingSenderId: "836911324936",
  appId: "1:836911324936:web:14366a57e08a220faa96bd",
  measurementId: "G-30ZWZQ0T4R"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

export { app, analytics };
