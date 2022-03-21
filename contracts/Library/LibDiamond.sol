pragma solidity ^0.7.6;
import "../Interface/IDiamondCut.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");



    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => address) selectorToFacet;
        // maps facet addresses to function selectors

        // facet addresses
        address[] facetAddresses;

        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(address facetAddress,IDiamondCut.FacetCutAction action , bytes4[]  functionSelectors);

    // Internal function version of diamondCut
    function diamondCut(
        address facetAddress,
        IDiamondCut.FacetCutAction _action,
        bytes4[] memory functionSelectors
    ) internal {
        // DiamondStorage storage ds = diamondStorage();
        require(msg.sender==contractOwner(),"Only Owner of contract can call diamondCut");

        IDiamondCut.FacetCutAction action = _action;
        if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(facetAddress, functionSelectors);
        } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(facetAddress, functionSelectors);
        } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(functionSelectors);
        } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        
        emit DiamondCut(facetAddress,_action,functionSelectors);
        // initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // uint16 selectorCount = uint16(diamondStorage().selectors.length);
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        
        for(uint256 i=0;i<_functionSelectors.length;i++){
            require(ds.selectorToFacet[_functionSelectors[i]]==address(0),"There already exists a function with the same header");
            ds.selectorToFacet[_functionSelectors[i]] = _facetAddress;
        }
        
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // uint16 selectorCount = uint16(diamondStorage().selectors.length);
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        
        for(uint256 i=0;i<_functionSelectors.length;i++){
            require(ds.selectorToFacet[_functionSelectors[i]]!=address(0),"LibDiamondCut: Function to replace does not exist");
            ds.selectorToFacet[_functionSelectors[i]] = _facetAddress;
        }
        
    }

    function removeFunctions(bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // uint16 selectorCount = uint16(diamondStorage().selectors.length);
        
        for(uint256 i=0;i<_functionSelectors.length;i++){
            require(ds.selectorToFacet[_functionSelectors[i]]!=address(0),"LibDiamondCut: Function to replace does not exist");
            ds.selectorToFacet[_functionSelectors[i]] = address(0);
        }
    }





    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}