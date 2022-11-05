// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment the line to use openzeppelin/ERC20
// You can use this dependency directly because it has been installed already
import "./StudentERC20.sol";

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
       
        // bool success; //提案是否通过
        uint numAgree;//赞成票的数量
        uint numDisagree;//反对票的数量
        mapping(address => uint) voteNum;//投票数量
        
    }

    // 提案状态
    enum ProposalStatus {
        BeingVoted, // 正在投票中
        Rejected, // 投票拒绝
        Approved, // 投票通过
        notStartYet // 投票还没开始
    }

    StudentERC20 studentERC20;
    uint tpNeedForProposal; // 发起提案需要消耗的通证积分
    uint tpNeedForVote; // 投票需要消耗的通证积分
    uint maxVotingTimes; // 最大投票次数

    uint32 public numProposals;  //num of proposals 
    mapping(uint => Proposal) proposals; // A map from proposal index to proposal
    
    struct Vote {
        bool isApprove; // 投票选择
        address voter; // 投票发起人
        uint voteTime; // 投票发起时间
        uint proposalIdVotedOn; // 投票对象
    }

    uint32 public numVotes;  //num of votes 
    mapping(uint => Vote) votes;

    constructor(uint _maxVotingTimes, uint _tpNeedForVote,uint _tpNeedForProposal, uint initStudentTP) {
        maxVotingTimes = _maxVotingTimes;
        tpNeedForVote = _tpNeedForVote;
        tpNeedForProposal = _tpNeedForProposal;
        studentERC20 = new StudentERC20("name", "symbol",initStudentTP);
    }

    /**
    * 发起提案
    * @param proposer 发起人
    * @param name 提案标题
    * @param duration 持续时间
    * @param startTime 开始时间
    */
    function newProposal(address payable proposer, string memory name, uint256 duration, uint256 startTime) public returns(uint) {

        require(startTime+duration>block.timestamp, "EndTime must be time in the future.");
        require(studentERC20.balanceOf(msg.sender) >= tpNeedForProposal, "Unable to afford a new proposal.");
        require(studentERC20.allowance(msg.sender, address(this)) >= tpNeedForProposal, "Don't have allowance over your TP.");

        studentERC20.transferFrom(msg.sender, address(this), tpNeedForProposal); // 委托本合约把用户的通证积分TP转账给本合约

        numProposals = numProposals + 1;
        Proposal storage p = proposals[numProposals];
        p.proposer = proposer;
        p.name = name;
        p.duration = duration;
        p.startTime = startTime;

        return numProposals;
    }

    // 获取提案信息
    function getProposalInfo(uint id, uint timeNow) public view returns (string memory, address, uint, uint, uint) {

        require(id<=numProposals && id >= 1, "This proposal doesn't exist.");

        uint status = uint(getProposalStatus(id, timeNow));
        string memory name = proposals[id].name;
        address proposer = proposals[id].proposer;
        uint startTime = proposals[id].startTime;
        uint duration = proposals[id].duration;

        return (name, proposer, startTime, duration, status);
    }

    // 获取提案状态
    function getProposalStatus(uint id) public view returns (ProposalStatus) {
        require(id<=numProposals && id >= 1, "This proposal doesn't exist.");

        // 检查是否超时
        if (block.timestamp > proposals[id].startTime + proposals[id].duration) {

            if (proposals[id].numAgree > proposals[id].numDisagree) {
                // 提案通过
                return ProposalStatus.Approved;
            } else {
                // 提案未通过
                return ProposalStatus.Rejected;
            }
        } else {
            if (block.timestamp < proposals[id].startTime) {
                // 提案投票还没开始
                return ProposalStatus.notStartYet;
            } else {
                // 提案正在投票
                return ProposalStatus.BeingVoted;
            }
        }
    }

    // 获取指定id的提案的投票信息
    function getProposalVotesInfo(uint id) public view returns (uint,uint) {
        uint numOfAgree = proposals[id].numAgree;
        uint numOfDisagree = proposals[id].numDisagree;

        return (numOfAgree,numOfDisagree);
    }

    // 获取提案状态
    function getProposalStatus(uint id,uint timeNow) public view returns (ProposalStatus) {
        require(id<=numProposals && id >= 1, "This proposal doesn't exist.");

        // 检查是否超时
        if (timeNow > proposals[id].startTime + proposals[id].duration) {

            if (proposals[id].numAgree > proposals[id].numDisagree) {
                // 提案通过
                return ProposalStatus.Approved;
            } else {
                // 提案未通过
                return ProposalStatus.Rejected;
            }
        } else {
            if (block.timestamp < proposals[id].startTime) {
                // 提案投票还没开始
                return ProposalStatus.notStartYet;
            } else {
                // 提案正在投票
                return ProposalStatus.BeingVoted;
            }
        }
    }

    // 发起一个新投票
    function newVote(bool choice, uint id) public {
        require(getProposalStatus(id) == ProposalStatus.BeingVoted, "Unable to vote on this proposal because voting has closed.");
        require(proposals[id].voteNum[msg.sender] < maxVotingTimes, "Unable to vote on this proposal because the maximum number of votes has been reached.");
        require(studentERC20.balanceOf(msg.sender) >= tpNeedForVote, "Unable to afford a new vote.");
        require(studentERC20.allowance(msg.sender, address(this)) >= tpNeedForVote, "DSOMW don't have allowance over your TP. Please authorize DSOMW.");

        studentERC20.transferFrom(msg.sender, address(this), tpNeedForVote); // 委托本合约把用户的通证积分TP转账给本合约（需要前端提前委托）

        numVotes = numVotes + 1;
        Vote storage v = votes[numVotes];
        v.voter = msg.sender;
        v.voteTime = block.timestamp;
        v.proposalIdVotedOn = id;
        v.isApprove = choice;

        proposals[id].voteNum[msg.sender] = proposals[id].voteNum[msg.sender]+1 ;
        if(v.isApprove) proposals[id].numAgree = proposals[id].numAgree+1;
        else proposals[id].numAgree = proposals[id].numDisagree+1;

    }

    function getTpNeedForProposal() public view returns (uint) {
        return tpNeedForProposal;
    }

    function getTpNeedForVote() public view returns (uint) {
        return tpNeedForVote;
    }

    // 获取最大投票次数
    function getMaxVotingTimes() public view returns (uint) {
        return maxVotingTimes;
    }

}
