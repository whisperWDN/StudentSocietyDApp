// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StudentERC20 is ERC20 {

    uint private initStudentTp; // 领取通证积分TP的数量
    mapping(address => bool) StudentList; //已经领取通证积分TP的名单

    constructor(string memory name, string memory symbol, uint _initialStudentTp) ERC20(name, symbol) {
        initStudentTp = _initialStudentTp;
    }

    // 获取可领取通证积分TP的数量
    function getInitialUserTp() public view returns (uint){
        return initStudentTp;
    }

    // 每个用户仅有一次领取通证积分TP的机会
    function getTP() public {
        
        require(StudentList[msg.sender] == false, "You have got TP already");
        StudentList[msg.sender] = true;

        _mint(msg.sender, initStudentTp);
    }

    // 判断用户是否可以领取初始通证积分
    function haveChanceToGetTP() public view returns (bool) {
        return !StudentList[msg.sender];
    }
}
