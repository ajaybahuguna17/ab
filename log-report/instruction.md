There is an Apache-style access log located at `/app/access.log`. Analyze the traffic logs and generate a JSON summary report saved exactly to `/app/report.json`.

### Success Criteria:
1. Parse the total log entries and output the count under the key `"total_requests"`.
2. Extract all unique client IP addresses and output the count under the key `"unique_ips"`.
3. Track target HTTP paths and identify the most frequently requested path under the key `"top_path"`.
4. Ensure the output is valid JSON formatting.