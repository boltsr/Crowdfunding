// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.8.9;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @author boltsr
 * @title CrowdFunding Project
 * @notice You can use this contract to manage the specific project.
 * @dev Individual project contract
 */
contract Project is Initializable {
    /// @notice mapping for fund contributor
    mapping(address => uint256) public fundContributors;

    /// @notice manager address of this project
    address public manager;

    /// @notice project deadline of fund
    uint256 public deadline;

    /// @notice target of project fund
    uint256 public targetAmount;

    /// @notice current status of fund
    uint256 public raisedAmount;

    /// @notice struct of user's request
    struct Request {
        // description of project
        string description;
        // recipient address after funding
        address payable recipient;
        // ether value of request
        uint256 value;
        //check if the request is approved
        bool completed;
    }

    /// @notice mapping for user requests
    mapping(uint256 => Request) public requests;

    /// @dev count of request
    uint256 public numRequests;

    /// @dev function modifier to be called the funciton by manager
    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    /// @notice Initialize the project
    /// @param _targetAmount target value of this project
    function initialize(uint256 _targetAmount, uint256 _deadline)
        public
        initializer
    {
        targetAmount = _targetAmount;
        deadline = block.timestamp + _deadline;
        manager = msg.sender;
    }

    /// @notice Send ether to this project.
    /// @dev Send ether using msg.value to this project contract.
    function sendFunds() public payable {
        require(block.timestamp < deadline, "crowdFunding is over");
        fundContributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    /// @notice Update the manager of this project.
    /// @dev Only current manager can modify the manager address.
    /// @param newManager new manager's address.
    function updateManager(address newManager) public onlyManager {
        manager = newManager;
    }

    /// @notice Show balance of this project.
    /// @dev Get balance of the project contract.
    /// @return ether balance of project.
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Refund the funds from project if the deadline is over but the raised money is less than target.
    /// @dev Send ether back to user .
    function refund() public {
        require(
            block.timestamp > deadline && raisedAmount < targetAmount,
            "You are not eligible for refund"
        );
        require(fundContributors[msg.sender] > 0);

        address payable user = payable(msg.sender);
        user.transfer(fundContributors[msg.sender]);
        fundContributors[msg.sender] = 0;
    }

    /// @notice Make request for the project
    /// @dev Store the allt the request data.
    function createRequest(
        string memory _description,
        address payable _recipient,
        uint256 _value
    ) public onlyManager {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
    }

    /// @notice Make payment according to request if the deadline is over and the riased fund is bigger than target.
    /// @dev Send ether to requested user according to requested amount.
    function makePayment(uint256 _requestNo) public onlyManager {
        require(raisedAmount >= targetAmount);
        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.completed == false,
            "This request has been completed"
        );
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}
