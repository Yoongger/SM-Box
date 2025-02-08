import React, { useState, useCallback, useEffect } from 'react';
import ReactFlow, {
  Controls,
  Background,
  useNodesState,
  useEdgesState,
  addEdge
} from 'reactflow';
import { fetchNodes, saveNodes } from '../services/api';

const nodeTypes = {
  filter: ({ data }) => (
    <div className="filter-node">
      <h4>{data.label}</h4>
      <input
        type="text"
        value={data.condition}
        onChange={data.onChange}
        placeholder="过滤条件"
      />
    </div>
  ),
  rule: ({ data }) => (
    <div className="rule-node">
      <h4>{data.label}</h4>
      <select value={data.ruleType} onChange={data.onChange}>
        <option value="DOMAIN">域名规则</option>
        <option value="IP-CIDR">IP规则</option>
        <option value="GEOIP">地区规则</option>
      </select>
    </div>
  )
};

const initialNodes = [{ id: '1', position: { x: 0, y: 0 }, data: { label: '起始节点' }, type: 'input' }];
const initialEdges = [];

const VisualEditor = () => {
  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
  const [edges, setEdges, onEdgesChange] = useEdgesState(initialEdges);
  const [selectedNode, setSelectedNode] = useState(null);

  // 修复useEffect依赖
useEffect(() => {
  const loadNodesData = async () => {
    try {
      const data = await fetchNodes();
      setNodes(data);
    } catch (error) {
      console.error('节点加载失败:', error);
    }
  };
  loadNodesData();
}, [setNodes]); // 添加setNodes到依赖数组

// 添加保存按钮处理（使用saveNodes）
const handleSave = async () => {
  try {
    await saveNodes(nodes);
    alert('节点保存成功！');
  } catch (error) {
    console.error('保存失败:', error);
    alert('保存失败，请检查控制台');
  }
};

  const onConnect = useCallback(
    (params) => setEdges((eds) => addEdge(params, eds)),
    [setEdges]
  );

  const createNode = (type) => {
    const newNode = {
      id: `${type}-${Date.now()}`,
      type,
      position: { x: 100, y: 100 },
      data: {
        label: `${type}节点`,
        onChange: (e) => handleNodeChange(newNode.id, e),
        ...(type === 'filter' ? { condition: '' } : { ruleType: 'DOMAIN' })
      }
    };
    setNodes((nds) => nds.concat(newNode));
  };

  const handleNodeChange = (id, event) => {
    setNodes((nds) =>
      nds.map((node) => {
        if (node.id === id) {
          return {
            ...node,
            data: {
              ...node.data,
              [event.target.name]: event.target.value
            }
          };
        }
        return node;
      })
    );
  };

  return (
    <div className="visual-editor">
      <div className="node-palette">
        <button onClick={() => createNode('filter')}>添加过滤器</button>
        <button onClick={() => createNode('rule')}>添加规则</button>
        <button onClick={handleSave} className="save-button">保存配置</button>
      </div>

      <div className="workspace" style={{ height: 600 }}>
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodesChange={onNodesChange}
          onEdgesChange={onEdgesChange}
          onConnect={onConnect}
          nodeTypes={nodeTypes}
          onNodeClick={(e, node) => setSelectedNode(node)}
        >
          <Background />
          <Controls />
        </ReactFlow>
      </div>

      {selectedNode && (
        <div className="properties-panel">
          <h3>节点属性</h3>
          {selectedNode.type === 'filter' ? (
            <input
              type="text"
              name="condition"
              value={selectedNode.data.condition}
              onChange={(e) => handleNodeChange(selectedNode.id, e)}
              placeholder="输入过滤条件"
            />
          ) : (
            <select
              name="ruleType"
              value={selectedNode.data.ruleType}
              onChange={(e) => handleNodeChange(selectedNode.id, e)}
            >
              <option value="DOMAIN">域名规则</option>
              <option value="IP-CIDR">IP规则</option>
              <option value="GEOIP">地区规则</option>
            </select>
          )}
        </div>
      )}
    </div>
  );
};

export default VisualEditor;