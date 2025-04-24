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

    // Record usage for a device
    function recordUsage(address device, uint256 usage) external onlyOwner {
        deviceUsage[device].totalUsage += usage;
        deviceUsage[device].lastUpdated = block.timestamp;
    }

    // Get the usage of a device
    function getUsage(address device) external view returns (uint256, uint256) {
        UsageRecord memory record = deviceUsage[device];
        return (record.totalUsage, record.lastUpdated);
    }

    // Reset usage for a device
    function resetUsage(address device) external onlyOwner {
        deviceUsage[device].totalUsage = 0;
        deviceUsage[device].lastUpdated = block.timestamp;
    }

    // Remove a device record
    function removeDevice(address device) external onlyOwner {
        delete deviceUsage[device];
    }

    // Manually set usage for a device
    function setUsage(address device, uint256 usage) external onlyOwner {
        deviceUsage[device].totalUsage = usage;
        deviceUsage[device].lastUpdated = block.timestamp;
    }

    // Transfer contract ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    // Check if a device has a usage record
    function isDeviceRegistered(address device) external view returns (bool) {
        return deviceUsage[device].lastUpdated != 0;
    }
}
