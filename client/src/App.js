// src/App.js

import React from 'react';
import './App.css';
import Navbar from './Navbar';

function App() {
  const connectWallet = () => {
    // Add code to connect the wallet here
    alert('Wallet connected!');
  };

  return (
    <div className="App">
      <Navbar connectWallet={connectWallet} />
      <div className="content">
        <h1>Welcome to My Wallet Website</h1>
      </div>
    </div>
  );
}

export default App;
