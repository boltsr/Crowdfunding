// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.8.9;
import "@openzeppelin/contracts/proxy/Clones.sol";

/**
 * @author boltsr
 * @title CrowdFunding Project
 * @notice You can use this contract to create the project and get the list of project.
 * @dev Pproject Factory contract
 */
import "./Project.sol";

contract ProjectFactory {
    /// @dev project list
    Project[] public projects;

    /// @dev implement address of project contract
    address projectImplement;

    /// @dev Init the factory contract.
    constructor(address _projectImplement) {
        projectImplement = _projectImplement;
    }

    /// @notice Create new project.
    /// @dev Init the new project and generate the project address.
    function createProject(uint256 _targetAmount, uint256 _deadline) public {
        Project newProject = Project(Clones.clone(projectImplement));
        newProject.initialize(_targetAmount, _deadline);
        newProject.updateManager(msg.sender);
        projects.push(newProject);
    }

    /// @notice Get the all the project.
    /// @dev Ge the list of project address.
    /// @return coll project list array

    function allProject() public view returns (Project[] memory coll) {
        return projects;
    }
}
