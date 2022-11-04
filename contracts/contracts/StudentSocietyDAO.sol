// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment the line to use openzeppelin/ERC20
// You can use this dependency directly because it has been installed already
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract StudentSocietyDAO {

    // use a event if you want
    event ProposalInitiated(uint32 proposalIndex);

    struct Proposal {
        uint32 index;      // index of this proposal
        address proposer;  // who make this proposal
        uint256 startTime; // proposal start time
        uint256 duration;  // proposal duration
        string name;       // proposal name
       
        bool success; //提案是否通过
    }

    ERC20 studentERC20;

    uint32 public numProposals;  //num of proposals 
    mapping(uint32 => Proposal) proposals; // A map from proposal index to proposal
    // ...
    // TODO add any variables if you want

    constructor() {
        // maybe you need a constructor
        studentERC20 = new ERC20("name", "symbol");
    }

    function helloworld() pure external returns(string memory) {
        return "hello world";
    }

    // ...
    // TODO add any logic if you want

    /**
    * 发起提案
    * @param proposer 发起人
    * @param name 提案标题
    * @param duration 持续时间
    * @param startTime 开始时间
    */
    function newFunding(address payable proposer, string memory name, uint256 duration, uint256 startTime) public returns(uint) {
        require(startTime > block.timestamp);

        numProposals = numProposals + 1;
        Proposal storage p = proposals[numProposals];
        p.proposer = proposer;
        p.name = name;
        p.duration = duration;
        p.startTime = startTime;
    
        return numProposals;
    }
}
