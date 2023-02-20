#pylint: disable=missing-docstring,redefined-outer-name

import pytest

@pytest.fixture
def dao_contract(w3, get_vyper_contract):
    with open("dao.vy", encoding='utf-8') as infile:
        contract_code = infile.read()

    return get_vyper_contract(contract_code)

def test_nothing(dao_contract):
    pass
