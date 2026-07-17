import json
from pathlib import Path

def test_report_exists():
    """Verifies Criterion 1: Confirm the report file is generated at the correct path."""
    assert Path("/app/report.json").exists(), "no report.json found"

def test_report_total_requests():
    """Verifies Criterion 2: Parse total requests from the log and verify it is a valid positive integer."""
    with open("/app/report.json", "r") as f:
        data = json.load(f)
    assert "total_requests" in data, "Missing 'total_requests' key"
    assert isinstance(data["total_requests"], int), "'total_requests' must be an integer"
    assert data["total_requests"] > 0, "total_requests must be greater than zero"

def test_report_unique_ips():
    """Verifies Criterion 3: Extract unique client IP addresses and verify it is a valid positive integer."""
    with open("/app/report.json", "r") as f:
        data = json.load(f)
    assert "unique_ips" in data, "Missing 'unique_ips' key"
    assert isinstance(data["unique_ips"], int), "'unique_ips' must be an integer"
    assert data["unique_ips"] > 0, "unique_ips must be greater than zero"

def test_report_top_path():
    """Verifies Criterion 4: Identify the most frequent HTTP request path as a valid string."""
    with open("/app/report.json", "r") as f:
        data = json.load(f)
    assert "top_path" in data, "Missing 'top_path' key"
    assert isinstance(data["top_path"], str), "'top_path' must be a string"
    assert len(data["top_path"].strip()) > 0, "'top_path' cannot be empty"