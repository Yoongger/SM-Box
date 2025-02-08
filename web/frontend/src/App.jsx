import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import SubscriptionConverter from './components/SubscriptionConverter';
import VisualEditor from './components/VisualEditor';
import AdBlockConfig from './components/AdBlockConfig';
import ProxySwitcher from './components/ProxySwitcher';
import './styles/main.css';

function App() {
  return (
    <Router>
      <div className="app-container">
        <nav>{/* 导航代码 */}</nav>

        <Routes>
          <Route path="/" element={<SubscriptionConverter />} />
          <Route path="/visual-editor" element={<VisualEditor />} />
          <Route path="/adblock-config" element={<AdBlockConfig />} />
          <Route path="/proxy-settings" element={<ProxySwitcher />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;