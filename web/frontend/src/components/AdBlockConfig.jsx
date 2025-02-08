import React, { useState, useEffect } from 'react';
import { getConfig, updateConfig } from '../services/api';

const AdBlockConfig = () => {
  const [config, setConfig] = useState({
    adBlockEnabled: true,
    filterLists: [],
    customFilters: ''
  });

  useEffect(() => {
    const loadConfig = async () => {
      const res = await getConfig();
      setConfig(res.data);
    };
    loadConfig();
  }, []);

  const handleSwitch = async () => {
    const newConfig = { ...config, adBlockEnabled: !config.adBlockEnabled };
    await updateConfig(newConfig);
    setConfig(newConfig);
  };

  const toggleFilterList = (url) => {
    setConfig(prev => ({
      ...prev,
      filterLists: prev.filterLists.map(list =>
        list.url === url ? { ...list, enabled: !list.enabled } : list
      )
    }));
  };

  return (
    <div className="adblock-config">
      <div className="switch-group">
        <label>广告拦截：</label>
        <input
          type="checkbox"
          checked={config.adBlockEnabled}
          onChange={handleSwitch}
        />
      </div>

      <div className="filter-lists">
        <h4>过滤规则列表</h4>
        <ul>
          {config.filterLists.map((list) => (
            <li key={list.url}>
              <input
                type="checkbox"
                checked={list.enabled}
                onChange={() => toggleFilterList(list.url)}
              />
              {list.name}
            </li>
          ))}
        </ul>
      </div>

      <div className="custom-filters">
        <h4>自定义规则</h4>
        <textarea
          value={config.customFilters}
          onChange={(e) => setConfig({...config, customFilters: e.target.value})}
          placeholder="每行一条过滤规则"
          rows={8}
        />
        <button onClick={() => updateConfig(config)}>保存规则</button>
      </div>
    </div>
  );
};

export default AdBlockConfig;