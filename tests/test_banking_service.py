from unittest.mock import MagicMock, patch
import pytest
from service.banking_service import (
    AccountNotFoundError,
    BankingService,
    DatabaseConnectionError,
    InsufficientFundsError,
    InvalidOperationError,
)
from service.config import DatabaseConfig


@pytest.fixture
def service():
    config = DatabaseConfig(host="localhost", port=3306, user="test", password="pw", database="bank_sys_final")
    return BankingService(config=config)


def test_deposit_validation(service):
    """Test that zero or negative deposit amounts raise InvalidOperationError."""
    with pytest.raises(InvalidOperationError, match="must be greater than zero"):
        service.deposit(account_id=1, amount=0)

    with pytest.raises(InvalidOperationError, match="must be greater than zero"):
        service.deposit(account_id=1, amount=-10.0)


def test_withdraw_validation(service):
    """Test that zero or negative withdrawal amounts raise InvalidOperationError."""
    with pytest.raises(InvalidOperationError, match="must be greater than zero"):
        service.withdraw(account_id=1, amount=0)

    with pytest.raises(InvalidOperationError, match="must be greater than zero"):
        service.withdraw(account_id=1, amount=-50.0)


def test_transfer_validation(service):
    """Test that transfers between identical accounts or with non-positive amounts raise errors."""
    with pytest.raises(InvalidOperationError, match="Source and destination accounts must differ"):
        service.transfer(source_account_id=1, destination_account_id=1, amount=100.0)

    with pytest.raises(InvalidOperationError, match="must be greater than zero"):
        service.transfer(source_account_id=1, destination_account_id=2, amount=0)


def test_call_procedure_execution(service):
    """Test _call_procedure executes stored procedure and commits."""
    mock_cursor = MagicMock()
    mock_result_set = MagicMock()
    mock_result_set.fetchall.return_value = [{"account_id": 1, "account_number": "AC001"}]
    mock_cursor.stored_results.return_value = [mock_result_set]

    mock_conn = MagicMock()
    mock_conn.cursor.return_value = mock_cursor
    mock_conn.is_connected.return_value = True

    with patch.object(service, "connection") as mock_ctx:
        mock_ctx.return_value.__enter__.return_value = mock_conn
        result = service.create_account(customer_id=1, account_type="CHECKING", opening_balance=100.0)

        mock_cursor.callproc.assert_called_once_with(
            "sp_create_account", [1, "CHECKING", "USD", 100.0, "service"]
        )
        assert result == {"account_id": 1, "account_number": "AC001"}
