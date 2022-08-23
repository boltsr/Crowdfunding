// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.8.9;
import "@openzeppelin/contracts/proxy/Clones.sol";

/**
 * @title ProjectFacotry contract
 * @dev CrowdFunding
 */
import "./Project.sol";

contract ProjectFactory {
    Project[] private _projects;
    address projectImplement;

    constructor(address _projectImplement) {
        projectImplement = _projectImplement;
    }

    function createProject(uint256 _targetAmount, uint256 _deadline) public {
        Project newProject = Project(Clones.clone(projectImplement));
        newProject.initialize(_targetAmount, _deadline);
        _projects.push(newProject);
    }

    function allProject() public view returns (Project[] memory coll) {
        return _projects;
    }
}
