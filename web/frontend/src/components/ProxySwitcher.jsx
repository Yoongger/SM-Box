import React, { useState, useEffect } from 'react';
import { getConfig, updateConfig } from '../services/api';

const proxyModes = [
  { value: 'direct', label: '直连模式' },
  { value: 'proxy', label: '全局代理' },
  { value: 'auto', label: '智能分流' },
  { value: 'rule', label: '规则代理' }
];

const ProxySwitcher = () => {
  const [mode, setMode] = useState('auto');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const loadMode = async () => {
      const res = await getConfig();
      setMode(res.data.proxyMode);
    };
    loadMode();
  }, []);

  const handleSwitch = async (newMode) => {
    setLoading(true);
    try {
      await updateConfig({ proxyMode: newMode });
      setMode(newMode);
    } catch (error) {
      console.error('切换失败:', error);
    }
    setLoading(false);
  };

  return (
    <div className="proxy-switcher">
      <h3>代理模式</h3>
      <div className="mode-buttons">
        {proxyModes.map(({ value, label }) => (
          <button
            key={value}
            className={mode === value ? 'active' : ''}
            onClick={() => handleSwitch(value)}
            disabled={loading}
          >
            {label}
          </button>
        ))}
      </div>
      <div className="mode-description">
        {proxyModes.find(m => m.value === mode)?.description}
      </div>
    </div>
  );
};

export default ProxySwitcher;