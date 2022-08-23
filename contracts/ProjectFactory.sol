import "./Project.sol";

contract FoundationFactory {
    Project[] private _projects;

    function createProject(string memory name) public {
        Project foundation = new Project(name, msg.sender);
        _projects.push(foundation);
    }

    function allProject(uint256 limit, uint256 offset)
        public
        view
        returns (Project[] memory coll)
    {
        return _projects;
    }
}
