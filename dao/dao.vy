from vyper.interfaces import ERC20

implements: ERC20

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)

# TODO add state that tracks proposals here

@external
def __init__():
    self.totalSupply = 0

@external
@payable
@nonreentrant("lock")
def buyToken():
    # TODO implement
    pass

@external
@nonpayable
@nonreentrant("lock")
def sellToken(_value: uint256):
    # TODO implement
    pass

# TODO add other ERC20 methods here

@external
@nonpayable
@nonreentrant("lock")
def createProposal(_uid: uint256, _recipient: address, _amount: uint256):
    # TODO implement
    pass

@external
@nonpayable
@nonreentrant("lock")
def approveProposal(_uid: uint256):
    # TODO implement
    pass
