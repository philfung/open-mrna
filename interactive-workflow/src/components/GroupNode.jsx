import React, { memo } from 'react';

const GroupNode = ({ data }) => {
  return (
    <div className="group-node-container">
      <div className="group-node-header">
        <span className="group-node-label">{data.label}</span>
      </div>
      <div className="group-node-body" />
    </div>
  );
};

export default memo(GroupNode);
