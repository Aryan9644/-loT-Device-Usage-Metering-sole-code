 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IoTDeviceMeter {
    address public owner;
    bool public isPaused;

    struct UsageRecord {
        uint256 totalUsage;
        uint256 lastUpdated;
        uint256 usageLimit;
    }

    mapping(address => UsageRecord) public deviceUsage;

    event UsageRecorded(address indexed device, uint256 amount, uint256 newTotal);
    event UsageReset(address indexed device);
    event DeviceRemoved(address indexed device);
    event UsageSet(address indexed device, uint256 newUsage);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event LimitSet(address indexed device, uint256 limit);
    event LimitExceeded(address indexed device, uint256 usage, uint256 limit);
    event Paused(bool isPaused);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyWhenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // === Core Functions ===

    function recordUsage(address device, uint256 usage) external onlyOwner onlyWhenNotPaused {
        deviceUsage[device].totalUsage += usage;
        deviceUsage[device].lastUpdated = block.timestamp;
        emit UsageRecorded(device, usage, deviceUsage[device].totalUsage);

        uint256 limit = deviceUsage[device].usageLimit;
        if (limit > 0 && deviceUsage[device].totalUsage > limit) {
            emit LimitExceeded(device, deviceUsage[device].totalUsage, limit);
        }
    }

    function getUsage(address device) external view returns (uint256 total, uint256 lastUpdated, uint256 limit) {
        UsageRecord memory record = deviceUsage[device];
        return (record.totalUsage, record.lastUpdated, record.usageLimit);
    }

    function resetUsage(address device) external onlyOwner {
        deviceUsage[device].totalUsage = 0;
        deviceUsage[device].lastUpdated = block.timestamp;
        emit UsageReset(device);
    }

    function removeDevice(address device) external onlyOwner {
        delete deviceUsage[device];
        emit DeviceRemoved(device);
    }

    function setUsage(address device, uint256 usage) external onlyOwner {
        deviceUsage[device].totalUsage = usage;
        deviceUsage[device].lastUpdated = block.timestamp;
        emit UsageSet(device, usage);
    }

    function isDeviceRegistered(address device) external view returns (bool) {
        return deviceUsage[device].lastUpdated != 0;
    }

    // === Admin Functions ===

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function togglePause() external onlyOwner {
        isPaused = !isPaused;
        emit Paused(isPaused);
    }

    // === Usage Limits ===

    function setUsageLimit(address device, uint256 limit) external onlyOwner {
        deviceUsage[device].usageLimit = limit;
        emit LimitSet(device, limit);
    }

    function getUsageLimit(address device) external view returns (uint256) {
        return deviceUsage[device].usageLimit;
    }

    // === Batch Functions ===

    function batchRecordUsage(address[] calldata devices, uint256[] calldata usages) external onlyOwner onlyWhenNotPaused {
        require(devices.length == usages.length, "Mismatched input lengths");
        for (uint256 i = 0; i < devices.length; i++) {
            recordUsage(devices[i], usages[i]);
        }
    }

    function batchResetUsage(address[] calldata devices) external onlyOwner {
        for (uint256 i = 0; i < devices.length; i++) {
            resetUsage(devices[i]);
        }
    }
}
