// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeMutualAidStation {
    // 定義捐贈者和接受者
    struct Donor {
        uint256 balance;
        uint256 tokenReceived;
    }

    struct Task {
        address taskOwner;
        bool isCompleted;
        bool isCancelled;
        uint256 tokenReward;
    }
    
    // 紀錄捐贈者和任務
    mapping(address => Donor) public donors;
    mapping(uint256 => Task) public tasks;
    uint256 public taskCounter;
    
    // NFT 名片紀錄 (僅作示範)
    mapping(address => string) public nftRecords;
    
    // 事件
    event TaskCreated(uint256 taskId, address indexed owner, uint256 reward);
    event TaskCompleted(uint256 taskId, address indexed owner, address indexed completer);
    event TaskCancelled(uint256 taskId, address indexed owner);
    event DonationReceived(address indexed donor, uint256 amount);
    
    // 創建任務
    function createTask(uint256 _reward) public {
        taskCounter++;
        tasks[taskCounter] = Task(msg.sender, false, false, _reward);
        emit TaskCreated(taskCounter, msg.sender, _reward);
    }
    
    // 完成任務
    function completeTask(uint256 _taskId) public {
        Task storage task = tasks[_taskId];
        require(task.isCancelled == false, "Task has been cancelled");
        require(task.isCompleted == false, "Task is already completed");
        
        // 獎勵發送 (假設 reward 來自捐贈)
        donors[msg.sender].tokenReceived += task.tokenReward;
        task.isCompleted = true;
        
        // 更新 NFT 記錄
        nftRecords[msg.sender] = "Task completed";
        emit TaskCompleted(_taskId, task.taskOwner, msg.sender);
    }
    
    // 取消任務
    function cancelTask(uint256 _taskId) public {
        Task storage task = tasks[_taskId];
        require(msg.sender == task.taskOwner, "Only task owner can cancel");
        require(task.isCompleted == false, "Cannot cancel a completed task");
        
        task.isCancelled = true;
        
        // 更新 NFT 記錄
        nftRecords[task.taskOwner] = "Task cancelled";
        emit TaskCancelled(_taskId, task.taskOwner);
    }
    
    // 接收捐贈
    function donate() public payable {
        donors[msg.sender].balance += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }
}
