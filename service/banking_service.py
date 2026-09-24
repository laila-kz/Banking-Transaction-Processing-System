import os
from contextlib import contextmanager
from typing import Any, Dict, List, Optional

try:
    import mysql.connector
    from mysql.connector import errorcode
except ImportError:
    mysql = None  # Handled gracefully if mocked or during linting

from service.config import DatabaseConfig


class BankingServiceError(Exception):
    """Base exception for banking service domain errors."""
    pass


class AccountNotFoundError(BankingServiceError):
    """Raised when the specified bank account does not exist."""
    pass


class InsufficientFundsError(BankingServiceError):
    """Raised when an account does not have sufficient funds for withdrawal or transfer."""
    pass


class DuplicateRequestError(BankingServiceError):
    """Raised when an operation is submitted with a previously processed idempotency key."""
    pass


class InvalidOperationError(BankingServiceError):
    """Raised when a business constraint or validation rule is violated."""
    pass


class DatabaseConnectionError(BankingServiceError):
    """Raised when the service is unable to connect to the MySQL database."""
    pass


class BankingService:
    """Core domain service interfacing with MySQL stored procedures."""

    def __init__(self, config: Optional[DatabaseConfig] = None):
        self.config = config or DatabaseConfig()
        self._db_params = {
            "host": self.config.host,
            "port": self.config.port,
            "user": self.config.user,
            "password": self.config.password,
            "database": self.config.database,
            "autocommit": False,
        }

    @contextmanager
    def connection(self):
        """Context manager for obtaining a database connection."""
        if mysql is None:
            raise DatabaseConnectionError("mysql-connector-python is not installed")
        
        try:
            conn = mysql.connector.connect(**self._db_params)
        except mysql.connector.Error as exc:
            raise DatabaseConnectionError(f"Database connection failed: {exc}") from exc

        try:
            yield conn
        finally:
            if conn.is_connected():
                conn.close()

    def check_health(self) -> Dict[str, Any]:
        """Verify database connectivity and return status."""
        try:
            with self.connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT 1")
                cursor.fetchone()
                cursor.close()
                return {"status": "healthy", "database": self.config.database}
        except Exception as exc:
            return {"status": "unhealthy", "error": str(exc)}

    def _call_procedure(self, procedure_name: str, args: list) -> List[Dict[str, Any]]:
        """Call a MySQL stored procedure and extract structured result sets."""
        with self.connection() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.callproc(procedure_name, args)
                results: List[Dict[str, Any]] = []
                for result in cursor.stored_results():
                    results.extend(result.fetchall())
                conn.commit()

                # Check if procedure returned a duplicate request notice
                if results and isinstance(results[0], dict) and results[0].get("status") == "DUPLICATE_REQUEST":
                    return results

                return results
            except mysql.connector.Error as exc:
                conn.rollback()
                err_msg = str(exc)
                if "Insufficient funds" in err_msg:
                    raise InsufficientFundsError(err_msg) from exc
                elif "not found" in err_msg.lower():
                    raise AccountNotFoundError(err_msg) from exc
                elif "cannot be negative" in err_msg or "must differ" in err_msg or "Only active" in err_msg:
                    raise InvalidOperationError(err_msg) from exc
                raise BankingServiceError(err_msg) from exc
            finally:
                cursor.close()

    def create_account(
        self,
        customer_id: int,
        account_type: str,
        currency: str = "USD",
        opening_balance: float = 0.0,
        actor: str = "service",
    ) -> Dict[str, Any]:
        """Create a new bank account with optional opening balance."""
        results = self._call_procedure(
            "sp_create_account",
            [customer_id, account_type.upper(), currency.upper(), float(opening_balance), actor],
        )
        if results and len(results) > 0:
            return results[0]
        return {"customer_id": customer_id, "status": "CREATED"}

    def close_account(self, account_id: int, actor: str = "service") -> Dict[str, Any]:
        """Close an existing bank account if balance is zero."""
        results = self._call_procedure("sp_close_account", [account_id, actor])
        if results and len(results) > 0:
            return results[0]
        return {"account_id": account_id, "status": "CLOSED"}

    def deposit(
        self,
        account_id: int,
        amount: float,
        idempotency_key: Optional[str] = None,
        actor: str = "service",
    ) -> Dict[str, Any]:
        """Deposit funds into an account."""
        if amount <= 0:
            raise InvalidOperationError("Deposit amount must be greater than zero")
        results = self._call_procedure("sp_deposit", [account_id, float(amount), idempotency_key, actor])
        if results and len(results) > 0:
            return results[0]
        return {"account_id": account_id, "amount": amount, "status": "POSTED"}

    def withdraw(
        self,
        account_id: int,
        amount: float,
        idempotency_key: Optional[str] = None,
        actor: str = "service",
    ) -> Dict[str, Any]:
        """Withdraw funds from an account."""
        if amount <= 0:
            raise InvalidOperationError("Withdrawal amount must be greater than zero")
        results = self._call_procedure("sp_withdraw", [account_id, float(amount), idempotency_key, actor])
        if results and len(results) > 0:
            return results[0]
        return {"account_id": account_id, "amount": amount, "status": "POSTED"}

    def transfer(
        self,
        source_account_id: int,
        destination_account_id: int,
        amount: float,
        idempotency_key: Optional[str] = None,
        actor: str = "service",
    ) -> Dict[str, Any]:
        """Transfer funds between two accounts."""
        if source_account_id == destination_account_id:
            raise InvalidOperationError("Source and destination accounts must differ")
        if amount <= 0:
            raise InvalidOperationError("Transfer amount must be greater than zero")

        results = self._call_procedure(
            "sp_transfer_funds",
            [source_account_id, destination_account_id, float(amount), idempotency_key, actor],
        )
        if results and len(results) > 0:
            return results[0]
        return {
            "source_account_id": source_account_id,
            "destination_account_id": destination_account_id,
            "amount": amount,
            "status": "POSTED",
        }

    def account_summary(self, account_id: int) -> Dict[str, Any]:
        """Retrieve details and balances for a specific account."""
        with self.connection() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.callproc("sp_get_account_summary", [account_id])
                results = []
                for result in cursor.stored_results():
                    results.extend(result.fetchall())
                if not results:
                    raise AccountNotFoundError(f"Account with ID {account_id} not found")
                return results[0]
            except mysql.connector.Error as exc:
                raise BankingServiceError(str(exc)) from exc
            finally:
                cursor.close()

    def transaction_history(
        self,
        account_id: int,
        from_date: Optional[str] = None,
        to_date: Optional[str] = None,
        limit: int = 100,
    ) -> List[Dict[str, Any]]:
        """Retrieve the transaction history and ledger records for an account."""
        with self.connection() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.callproc("sp_get_transaction_history", [account_id, from_date, to_date, limit])
                results = []
                for result in cursor.stored_results():
                    results.extend(result.fetchall())
                return results
            except mysql.connector.Error as exc:
                raise BankingServiceError(str(exc)) from exc
            finally:
                cursor.close()