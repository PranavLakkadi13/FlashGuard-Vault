// src/Navbar.js

import React from 'react';

const Navbar = ({ connectWallet }) => {
    return (
        <nav>
            <div className="container">
                <div className="navbar">
                    <div className="logo">My Wallet Website</div>
                    <div className="buttons">
                        <button onClick={connectWallet}>Connect Wallet</button>
                    </div>
                </div>
            </div>
        </nav>
    );
};

export default Navbar;
