import axios from 'axios';

const api = axios.create({
    baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8080/api',
});

// 配置相关
export const getConfig = () => api.get('/config');
export const updateConfig = (config) => api.put('/config', config);

// 订阅相关
export const convertSubscription = (config) => api.post('/subscribe/convert', config);
export const updateSubscriptions = (sources) => api.post('/update/subscriptions', { sources });
export const updateRules = (content) => api.post('/update/rules', { content });

// 代理相关
export const setProxyMode = (mode) => api.put('/proxy/mode', { mode });
export const getProxyStatus = () => api.get('/proxy/status');
export const fetchNodes = () => api.get('/visual/nodes');
export const saveNodes = (nodes) => api.post('/visual/nodes', { nodes });
export default api;