from unittest.mock import MagicMock
import pytest
from service.app import create_app
from service.banking_service import (
    AccountNotFoundError,
    BankingService,
    BankingServiceError,
    DuplicateRequestError,
    InsufficientFundsError,
    InvalidOperationError,
)


@pytest.fixture
def mock_service():
    """Create a mock BankingService instance."""
    service = MagicMock(spec=BankingService)
    service.check_health.return_value = {"status": "healthy", "database": "bank_sys_final"}
    return service


@pytest.fixture
def client(mock_service):
    """Create a Flask test client with the mocked service."""
    app = create_app(service=mock_service)
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_index_route(client):
    """Test the root index endpoint returns API information."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert "service" in data
    assert "endpoints" in data


def test_health_route_healthy(client, mock_service):
    """Test health endpoint when database is connected."""
    mock_service.check_health.return_value = {"status": "healthy", "database": "bank_sys_final"}
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"


def test_health_route_unhealthy(client, mock_service):
    """Test health endpoint when database check fails."""
    mock_service.check_health.return_value = {"status": "unhealthy", "error": "Connection refused"}
    response = client.get("/health")
    assert response.status_code == 503
    data = response.get_json()
    assert data["status"] == "unhealthy"


def test_create_account_success(client, mock_service):
    """Test successful account creation."""
    mock_service.create_account.return_value = {
        "account_id": 101,
        "account_number": "AC00000001XYZ",
    }
    payload = {
        "customer_id": 1,
        "account_type": "CHECKING",
        "currency": "USD",
        "opening_balance": 500.0,
    }
    response = client.post("/accounts", json=payload)
    assert response.status_code == 201
    data = response.get_json()
    assert data["ok"] is True
    assert data["result"]["account_id"] == 101


def test_create_account_missing_fields(client):
    """Test account creation with missing fields."""
    response = client.post("/accounts", json={"customer_id": 1})
    assert response.status_code == 400
    data = response.get_json()
    assert data["ok"] is False
    assert "Missing required fields" in data["error"]


def test_create_account_customer_not_found(client, mock_service):
    """Test account creation when customer is not found."""
    mock_service.create_account.side_effect = AccountNotFoundError("Customer not found")
    response = client.post("/accounts", json={"customer_id": 999, "account_type": "CHECKING"})
    assert response.status_code == 404
    data = response.get_json()
    assert data["ok"] is False


def test_deposit_success(client, mock_service):
    """Test successful deposit."""
    mock_service.deposit.return_value = {
        "transaction_id": 5001,
        "reference_number": "DEP-12345",
        "status": "POSTED",
    }
    response = client.post("/accounts/101/deposit", json={"amount": 250.0, "idempotency_key": "k-1"})
    assert response.status_code == 200
    data = response.get_json()
    assert data["ok"] is True
    assert data["result"]["status"] == "POSTED"


def test_deposit_negative_amount(client, mock_service):
    """Test deposit with negative amount."""
    mock_service.deposit.side_effect = InvalidOperationError("Deposit amount must be greater than zero")
    response = client.post("/accounts/101/deposit", json={"amount": -50.0})
    assert response.status_code == 400
    data = response.get_json()
    assert data["ok"] is False


def test_withdraw_success(client, mock_service):
    """Test successful withdrawal."""
    mock_service.withdraw.return_value = {
        "transaction_id": 5002,
        "reference_number": "WTH-12345",
        "status": "POSTED",
    }
    response = client.post("/accounts/101/withdraw", json={"amount": 100.0})
    assert response.status_code == 200
    data = response.get_json()
    assert data["ok"] is True


def test_withdraw_insufficient_funds(client, mock_service):
    """Test withdrawal exceeding account balance."""
    mock_service.withdraw.side_effect = InsufficientFundsError("Insufficient funds")
    response = client.post("/accounts/101/withdraw", json={"amount": 999999.0})
    assert response.status_code == 400
    data = response.get_json()
    assert data["ok"] is False
    assert "Insufficient funds" in data["error"]


def test_transfer_success(client, mock_service):
    """Test successful transfer between two accounts."""
    mock_service.transfer.return_value = {
        "transaction_id": 5003,
        "reference_number": "TRF-12345",
        "status": "POSTED",
    }
    payload = {
        "source_account_id": 101,
        "destination_account_id": 102,
        "amount": 75.0,
    }
    response = client.post("/transfers", json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["ok"] is True


def test_transfer_same_account(client, mock_service):
    """Test transfer when source and destination are identical."""
    mock_service.transfer.side_effect = InvalidOperationError("Source and destination accounts must differ")
    payload = {
        "source_account_id": 101,
        "destination_account_id": 101,
        "amount": 50.0,
    }
    response = client.post("/transfers", json=payload)
    assert response.status_code == 400
    data = response.get_json()
    assert data["ok"] is False


def test_close_account(client, mock_service):
    """Test closing an account."""
    mock_service.close_account.return_value = {"account_id": 101, "status": "CLOSED"}
    response = client.post("/accounts/101/close")
    assert response.status_code == 200
    data = response.get_json()
    assert data["ok"] is True
    assert data["result"]["status"] == "CLOSED"


def test_account_summary_success(client, mock_service):
    """Test fetching account summary."""
    mock_service.account_summary.return_value = {
        "account_id": 101,
        "account_number": "AC00000001",
        "account_type": "CHECKING",
        "balance": 1500.0,
        "customer_id": 1,
        "full_name": "John Doe",
    }
    response = client.get("/accounts/101")
    assert response.status_code == 200
    data = response.get_json()
    assert data["ok"] is True
    assert data["result"]["balance"] == 1500.0


def test_account_summary_not_found(client, mock_service):
    """Test fetching summary for non-existent account."""
    mock_service.account_summary.side_effect = AccountNotFoundError("Account with ID 999 not found")
    response = client.get("/accounts/999")
    assert response.status_code == 404
    data = response.get_json()
    assert data["ok"] is False


def test_transaction_history(client, mock_service):
    """Test retrieving transaction history."""
    mock_service.transaction_history.return_value = [
        {"transaction_id": 1, "amount": 100.0, "transaction_type": "DEPOSIT"},
        {"transaction_id": 2, "amount": 50.0, "transaction_type": "WITHDRAWAL"},
    ]
    response = client.get("/accounts/101/history?limit=10")
    assert response.status_code == 200
    data = response.get_json()
    assert data["ok"] is True
    assert data["count"] == 2
    assert len(data["result"]) == 2
