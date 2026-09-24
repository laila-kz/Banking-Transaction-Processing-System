import os
from flask import Flask, jsonify, request

from service.banking_service import (
    AccountNotFoundError,
    BankingService,
    BankingServiceError,
    DuplicateRequestError,
    InsufficientFundsError,
    InvalidOperationError,
)
from service.config import APIConfig, DatabaseConfig


def create_app(service: BankingService = None):
    """Factory to create and configure the Flask application."""
    app = Flask(__name__)
    api_config = APIConfig()
    db_config = DatabaseConfig()

    if service is None:
        service = BankingService(config=db_config)

    @app.get("/")
    def index():
        return jsonify({
            "service": "Core Banking System API",
            "version": "1.0.0",
            "environment": api_config.env,
            "endpoints": {
                "health": "/health",
                "create_account": "POST /accounts",
                "get_account": "GET /accounts/<account_id>",
                "close_account": "POST /accounts/<account_id>/close",
                "deposit": "POST /accounts/<account_id>/deposit",
                "withdraw": "POST /accounts/<account_id>/withdraw",
                "transfer": "POST /transfers",
                "history": "GET /accounts/<account_id>/history",
            },
        })

    @app.get("/health")
    def health():
        status = service.check_health()
        http_code = 200 if status.get("status") == "healthy" else 503
        return jsonify(status), http_code

    @app.post("/accounts")
    def create_account():
        payload = request.get_json(force=True) if request.is_json or request.data else {}
        if not payload or "customer_id" not in payload or "account_type" not in payload:
            return jsonify({
                "ok": False,
                "error": "Missing required fields: 'customer_id' and 'account_type'",
            }), 400

        try:
            result = service.create_account(
                customer_id=int(payload["customer_id"]),
                account_type=str(payload["account_type"]),
                currency=payload.get("currency", "USD"),
                opening_balance=float(payload.get("opening_balance", 0.0)),
                actor=payload.get("actor", "api"),
            )
            return jsonify({"ok": True, "result": result}), 201
        except (ValueError, KeyError, InvalidOperationError) as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400
        except AccountNotFoundError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 404
        except BankingServiceError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400

    @app.post("/accounts/<int:account_id>/close")
    def close_account(account_id: int):
        payload = request.get_json(force=True) if request.is_json or request.data else {}
        actor = payload.get("actor", "api") if isinstance(payload, dict) else "api"
        try:
            result = service.close_account(account_id=account_id, actor=actor)
            return jsonify({"ok": True, "result": result}), 200
        except AccountNotFoundError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 404
        except (InvalidOperationError, BankingServiceError) as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400

    @app.post("/accounts/<int:account_id>/deposit")
    def deposit(account_id: int):
        payload = request.get_json(force=True) if request.is_json or request.data else {}
        if not payload or "amount" not in payload:
            return jsonify({"ok": False, "error": "Missing required field: 'amount'"}), 400

        try:
            amount = float(payload["amount"])
            result = service.deposit(
                account_id=account_id,
                amount=amount,
                idempotency_key=payload.get("idempotency_key"),
                actor=payload.get("actor", "api"),
            )
            return jsonify({"ok": True, "result": result}), 200
        except (ValueError, KeyError, InvalidOperationError) as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400
        except AccountNotFoundError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 404
        except DuplicateRequestError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 409
        except BankingServiceError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400

    @app.post("/accounts/<int:account_id>/withdraw")
    def withdraw(account_id: int):
        payload = request.get_json(force=True) if request.is_json or request.data else {}
        if not payload or "amount" not in payload:
            return jsonify({"ok": False, "error": "Missing required field: 'amount'"}), 400

        try:
            amount = float(payload["amount"])
            result = service.withdraw(
                account_id=account_id,
                amount=amount,
                idempotency_key=payload.get("idempotency_key"),
                actor=payload.get("actor", "api"),
            )
            return jsonify({"ok": True, "result": result}), 200
        except InsufficientFundsError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400
        except (ValueError, KeyError, InvalidOperationError) as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400
        except AccountNotFoundError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 404
        except DuplicateRequestError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 409
        except BankingServiceError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400

    @app.post("/transfers")
    def transfer():
        payload = request.get_json(force=True) if request.is_json or request.data else {}
        required = ["source_account_id", "destination_account_id", "amount"]
        if not payload or any(field not in payload for field in required):
            return jsonify({
                "ok": False,
                "error": f"Missing one or more required fields: {', '.join(required)}",
            }), 400

        try:
            result = service.transfer(
                source_account_id=int(payload["source_account_id"]),
                destination_account_id=int(payload["destination_account_id"]),
                amount=float(payload["amount"]),
                idempotency_key=payload.get("idempotency_key"),
                actor=payload.get("actor", "api"),
            )
            return jsonify({"ok": True, "result": result}), 200
        except InsufficientFundsError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400
        except (ValueError, KeyError, InvalidOperationError) as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400
        except AccountNotFoundError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 404
        except DuplicateRequestError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 409
        except BankingServiceError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400

    @app.get("/accounts/<int:account_id>")
    def account_summary(account_id: int):
        try:
            result = service.account_summary(account_id)
            return jsonify({"ok": True, "result": result}), 200
        except AccountNotFoundError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 404
        except BankingServiceError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400

    @app.get("/accounts/<int:account_id>/history")
    def transaction_history(account_id: int):
        from_date = request.args.get("from_date")
        to_date = request.args.get("to_date")
        limit = request.args.get("limit", 100, type=int)

        try:
            result = service.transaction_history(
                account_id=account_id,
                from_date=from_date,
                to_date=to_date,
                limit=limit,
            )
            return jsonify({"ok": True, "result": result, "count": len(result)}), 200
        except AccountNotFoundError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 404
        except BankingServiceError as exc:
            return jsonify({"ok": False, "error": str(exc)}), 400

    @app.errorhandler(404)
    def not_found(e):
        return jsonify({"ok": False, "error": "Endpoint not found"}), 404

    @app.errorhandler(500)
    def internal_error(e):
        return jsonify({"ok": False, "error": "Internal server error"}), 500

    return app


if __name__ == "__main__":
    api_cfg = APIConfig()
    app = create_app()
    app.run(host=api_cfg.host, port=api_cfg.port, debug=api_cfg.debug)