pragma solidity ^0.7.6;
import "./Interface/IDiamondCut.sol";
import "./Library/LibDiamond.sol";
contract Diamond {
    // more arguments are added to this struct
    // this avoids stack too deep errors


    constructor( address facetAddress,IDiamondCut.FacetCutAction _action,bytes4[] memory functionSelectors) {
        LibDiamond.diamondCut( facetAddress,_action, functionSelectors);
        LibDiamond.setContractOwner(msg.sender);

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address facet = ds.selectorToFacet[msg.sig];
        require(facet != address(0), "Diamond: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }
}