#!/usr/bin/env python3
"""API Testing Script - Tests the running API server."""
import os
import sys
import json
import requests
from typing import Optional

API_URL = os.getenv("API_URL", "http://127.0.0.1:8000")
BASE_URL = f"{API_URL}/v1"

# Colors
GREEN = "\033[0;32m"
RED = "\033[0;31m"
YELLOW = "\033[1;33m"
NC = "\033[0m"  # No Color

passed = 0
failed = 0
token: Optional[str] = None


def test_endpoint(
    method: str,
    endpoint: str,
    data: Optional[dict] = None,
    expected_status: int = 200,
    description: str = "",
    headers: Optional[dict] = None,
) -> bool:
    """Test an API endpoint."""
    global passed, failed
    
    url = f"{BASE_URL}{endpoint}"
    if headers is None:
        headers = {}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    
    try:
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=5)
        elif method == "POST":
            headers["Content-Type"] = "application/json"
            response = requests.post(url, json=data, headers=headers, timeout=5)
        else:
            print(f"{RED}❌{NC} Unknown method: {method}")
            failed += 1
            return False
        
        if response.status_code == expected_status:
            print(f"{GREEN}✅{NC} {description or endpoint}")
            passed += 1
            return True
        else:
            print(f"{RED}❌{NC} {description or endpoint} (Expected {expected_status}, got {response.status_code})")
            try:
                error_body = response.json()
                if "error" in error_body:
                    print(f"   Error: {error_body['error'].get('message', 'Unknown error')}")
            except:
                print(f"   Response: {response.text[:100]}")
            failed += 1
            return False
    except Exception as e:
        print(f"{RED}❌{NC} {description or endpoint} - Exception: {e}")
        failed += 1
        return False


def main():
    global token, passed, failed
    
    print(f"{YELLOW}🧪 Testing Talkam Liberia API{NC}")
    print(f"API URL: {BASE_URL}\n")
    
    # 1. Health check
    print("1. Health Check")
    test_endpoint("GET", "/health", expected_status=200, description="Health check")
    print()
    
    # 2. Anonymous auth
    print("2. Authentication")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/anonymous-start",
            json={"device_hash": f"test-device-{os.getpid()}", "county": "Montserrado"},
            timeout=5,
        )
        if response.status_code == 200:
            data = response.json()
            token = data.get("token")
            if token:
                print(f"{GREEN}✅{NC} Anonymous authentication")
                passed += 1
            else:
                print(f"{RED}❌{NC} No token in response")
                failed += 1
        else:
            print(f"{RED}❌{NC} Anonymous auth failed: {response.status_code}")
            failed += 1
    except Exception as e:
        print(f"{RED}❌{NC} Anonymous auth exception: {e}")
        failed += 1
    print()
    
    if not token:
        print(f"{RED}⚠️  Cannot continue without authentication token{NC}")
        print(f"Summary: {GREEN}Passed: {passed}{NC}, {RED}Failed: {failed}{NC}")
        sys.exit(1)
    
    # 3. Create report
    print("3. Report Creation")
    report_data = {
        "category": "infrastructure",
        "severity": "high",
        "summary": "Test report for API testing",
        "details": "This is a test report created during API testing",
        "location": {
            "latitude": 6.4281,
            "longitude": -10.7619,
            "county": "Montserrado",
        },
        "anonymous": False,
    }
    
    report_id = None
    if test_endpoint("POST", "/reports/create", data=report_data, expected_status=201, description="Create report"):
        try:
            response = requests.post(
                f"{BASE_URL}/reports/create",
                json=report_data,
                headers={"Authorization": f"Bearer {token}"},
                timeout=5,
            )
            if response.status_code == 201:
                report_id = response.json().get("id")
                print(f"   Report ID: {report_id}")
        except:
            pass
    print()
    
    # 4. Search & Filtering
    print("4. Search & Filtering")
    test_endpoint("GET", "/reports/search?category=infrastructure", description="Search by category")
    test_endpoint("GET", "/reports/search?severity=high", description="Search by severity")
    test_endpoint("GET", "/reports/search?min_priority=0.5", description="Search by priority")
    test_endpoint("GET", "/reports/search?sort_by=priority_score&sort_order=desc", description="Search with sorting")
    test_endpoint("GET", "/reports/search?text=test", description="Full-text search")
    print()
    
    # 5. Analytics (may fail without admin token, that's okay)
    print("5. Analytics Endpoints")
    test_endpoint("GET", "/dashboards/analytics", description="Analytics dashboard", expected_status=200)
    test_endpoint("GET", "/dashboards/heatmap?days=30", description="Geographic heatmap", expected_status=200)
    test_endpoint("GET", "/dashboards/category-insights", description="Category insights", expected_status=200)
    test_endpoint("GET", "/dashboards/time-series?days=30&group_by=day", description="Time series", expected_status=200)
    print()
    
    # 6. Notifications
    print("6. Notifications")
    test_endpoint("GET", "/notifications", description="Get notifications")
    test_endpoint("GET", "/notifications/unread/count", description="Get unread count")
    print()
    
    # 7. Attestations (if report was created)
    if report_id:
        print("7. Attestations")
        attest_data = {
            "action": "confirm",
            "confidence": "high",
            "comment": "I can confirm this report",
        }
        test_endpoint(
            "POST",
            f"/attestations/reports/{report_id}/attest",
            data=attest_data,
            expected_status=201,
            description="Attest to report",
        )
        print()
    
    # Summary
    print("━" * 60)
    print("Test Summary:")
    print(f"{GREEN}Passed: {passed}{NC}")
    if failed > 0:
        print(f"{RED}Failed: {failed}{NC}")
        sys.exit(1)
    else:
        print(f"{GREEN}Failed: {failed}{NC}")
        sys.exit(0)


if __name__ == "__main__":
    main()
