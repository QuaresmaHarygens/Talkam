#!/usr/bin/env python3
"""
Load testing script for Talkam Liberia API.
Uses locust-style approach for simplicity.
"""
import asyncio
import aiohttp
import time
import random
from typing import List, Dict
from dataclasses import dataclass

@dataclass
class TestResult:
    endpoint: str
    status_code: int
    response_time: float
    success: bool

class LoadTester:
    def __init__(self, base_url: str, num_users: int = 10, duration: int = 60):
        self.base_url = base_url
        self.num_users = num_users
        self.duration = duration
        self.results: List[TestResult] = []
        self.tokens: List[str] = []

    async def register_user(self, session: aiohttp.ClientSession, phone: str) -> str:
        """Register a test user and get auth token."""
        try:
            async with session.post(
                f"{self.base_url}/v1/auth/register",
                json={
                    "phone": phone,
                    "password": "TestPass123!",
                    "full_name": f"Test User {phone}",
                },
            ) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    return data.get("access_token", "")
        except Exception:
            pass
        return ""

    async def create_report(self, session: aiohttp.ClientSession, token: str) -> TestResult:
        """Create a test report."""
        start_time = time.time()
        try:
            async with session.post(
                f"{self.base_url}/v1/reports/create",
                headers={"Authorization": f"Bearer {token}"},
                json={
                    "category": random.choice(["infrastructure", "security", "health"]),
                    "severity": random.choice(["low", "medium", "high"]),
                    "summary": f"Load test report {random.randint(1000, 9999)}",
                    "location": {
                        "latitude": 6.3 + random.uniform(-0.5, 0.5),
                        "longitude": -10.8 + random.uniform(-0.5, 0.5),
                        "county": random.choice(["Montserrado", "Bomi", "Bong"]),
                    },
                    "anonymous": random.choice([True, False]),
                },
            ) as resp:
                response_time = time.time() - start_time
                return TestResult(
                    endpoint="/v1/reports/create",
                    status_code=resp.status,
                    response_time=response_time,
                    success=resp.status == 201,
                )
        except Exception as e:
            response_time = time.time() - start_time
            return TestResult(
                endpoint="/v1/reports/create",
                status_code=0,
                response_time=response_time,
                success=False,
            )

    async def get_reports(self, session: aiohttp.ClientSession, token: str) -> TestResult:
        """Fetch reports list."""
        start_time = time.time()
        try:
            async with session.get(
                f"{self.base_url}/v1/reports/search",
                headers={"Authorization": f"Bearer {token}"},
            ) as resp:
                response_time = time.time() - start_time
                return TestResult(
                    endpoint="/v1/reports/search",
                    status_code=resp.status,
                    response_time=response_time,
                    success=resp.status == 200,
                )
        except Exception as e:
            response_time = time.time() - start_time
            return TestResult(
                endpoint="/v1/reports/search",
                status_code=0,
                response_time=response_time,
                success=False,
            )

    async def user_simulation(self, session: aiohttp.ClientSession, user_id: int):
        """Simulate a single user's behavior."""
        phone = f"231770{user_id:06d}"
        token = await self.register_user(session, phone)
        
        if not token:
            print(f"Failed to register user {user_id}")
            return

        end_time = time.time() + self.duration
        while time.time() < end_time:
            # Randomly perform actions
            action = random.choices(
                [self.create_report, self.get_reports],
                weights=[0.3, 0.7],
                k=1
            )[0]

            result = await action(session, token)
            self.results.append(result)

            # Random delay between actions (1-5 seconds)
            await asyncio.sleep(random.uniform(1, 5))

    async def run(self):
        """Run the load test."""
        print(f"Starting load test with {self.num_users} users for {self.duration} seconds...")
        
        async with aiohttp.ClientSession() as session:
            tasks = [
                self.user_simulation(session, i)
                for i in range(self.num_users)
            ]
            await asyncio.gather(*tasks)

    def print_results(self):
        """Print test results summary."""
        if not self.results:
            print("No results collected.")
            return

        total_requests = len(self.results)
        successful = sum(1 for r in self.results if r.success)
        failed = total_requests - successful
        
        response_times = [r.response_time for r in self.results]
        avg_response_time = sum(response_times) / len(response_times)
        p95_response_time = sorted(response_times)[int(len(response_times) * 0.95)]
        p99_response_time = sorted(response_times)[int(len(response_times) * 0.99)]

        print("\n" + "="*60)
        print("LOAD TEST RESULTS")
        print("="*60)
        print(f"Total Requests: {total_requests}")
        print(f"Successful: {successful} ({successful/total_requests*100:.2f}%)")
        print(f"Failed: {failed} ({failed/total_requests*100:.2f}%)")
        print(f"\nResponse Times:")
        print(f"  Average: {avg_response_time:.3f}s")
        print(f"  P95: {p95_response_time:.3f}s")
        print(f"  P99: {p99_response_time:.3f}s")
        
        # Status code breakdown
        status_codes = {}
        for r in self.results:
            status_codes[r.status_code] = status_codes.get(r.status_code, 0) + 1
        
        print(f"\nStatus Codes:")
        for code, count in sorted(status_codes.items()):
            print(f"  {code}: {count}")
        
        # Endpoint breakdown
        endpoints = {}
        for r in self.results:
            endpoints[r.endpoint] = endpoints.get(r.endpoint, [])
            endpoints[r.endpoint].append(r)
        
        print(f"\nPer-Endpoint:")
        for endpoint, results in endpoints.items():
            success_rate = sum(1 for r in results if r.success) / len(results) * 100
            avg_time = sum(r.response_time for r in results) / len(results)
            print(f"  {endpoint}:")
            print(f"    Success Rate: {success_rate:.2f}%")
            print(f"    Avg Time: {avg_time:.3f}s")
        
        print("="*60)

async def main():
    import sys
    
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000"
    num_users = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    duration = int(sys.argv[3]) if len(sys.argv) > 3 else 60
    
    tester = LoadTester(base_url, num_users, duration)
    await tester.run()
    tester.print_results()

if __name__ == "__main__":
    asyncio.run(main())
