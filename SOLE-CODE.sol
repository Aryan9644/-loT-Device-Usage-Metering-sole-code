// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IoTDeviceMeter {
    address public owner;

    struct UsageRecord {
        uint256 totalUsage;
        uint256 lastUpdated;
    }

    mapping(address => UsageRecord) public deviceUsage;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to record usage for a device
    function recordUsage(address device, uint256 usage) external onlyOwner {
        deviceUsage[device].totalUsage += usage;
        deviceUsage[device].lastUpdated = block.timestamp;
    }

    // Function to retrieve the usage of a device
    function getUsage(address device) external view returns (uint256, uint256) {
        UsageRecord memory record = deviceUsage[device];
        return (record.totalUsage, record.lastUpdated);
    }
}
