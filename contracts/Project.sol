// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.8.9;
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @title Project contract
 * @dev CrowdFunding
 */
contract Project is Initializable {
    mapping(address => uint256) public fundContributors;
    address public manager;
    uint256 public deadline;
    uint256 public targetAmount;
    uint256 public raisedAmount;

    struct Request {
        string description;
        address payable recipient;
        uint256 value;
        bool completed;
    }

    mapping(uint256 => Request) public requests;
    uint256 public numRequests;

    function initialize(uint256 _targetAmount, uint256 _deadline)
        public
        initializer
    {
        targetAmount = _targetAmount;
        deadline = block.timestamp + _deadline;
        manager = msg.sender;
    }

    function sendFunds() public payable {
        require(block.timestamp < deadline, "crowdFunding is over");
        fundContributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

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

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

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
