# Load Testing Tools

## Python Load Tester

Simple load testing script using asyncio and aiohttp.

### Usage

```bash
python load_test.py [API_URL] [NUM_USERS] [DURATION_SECONDS]
```

### Examples

```bash
# Test local API with 10 users for 60 seconds
python load_test.py http://127.0.0.1:8000 10 60

# Test production API with 50 users for 5 minutes
python load_test.py https://api.talkam.liberia.com 50 300
```

### Output

The script will print:
- Total requests and success rate
- Response time statistics (average, P95, P99)
- Status code breakdown
- Per-endpoint performance metrics

## Locust (Alternative)

For more advanced load testing, use Locust:

```bash
pip install locust

# Create locustfile.py
locust -f locustfile.py --host=http://127.0.0.1:8000 --users=100 --spawn-rate=10
```

## k6 (Alternative)

For script-based load testing:

```bash
# Install k6
brew install k6  # macOS
# or download from https://k6.io

# Run test
k6 run k6_test.js
```

## Recommended Test Scenarios

1. **Light Load**: 10-20 users, 60 seconds
2. **Normal Load**: 50-100 users, 5 minutes
3. **Heavy Load**: 200-500 users, 10 minutes
4. **Stress Test**: 1000+ users, 15 minutes

## Performance Targets

- Response time P95: < 500ms
- Response time P99: < 1s
- Success rate: > 99%
- Throughput: > 100 req/s
