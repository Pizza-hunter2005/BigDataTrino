#!/bin/bash
set -e

for file in "/data/MOCK_DATA.csv" "/data/MOCK_DATA (1).csv" "/data/MOCK_DATA (2).csv" "/data/MOCK_DATA (3).csv" "/data/MOCK_DATA (4).csv"; do
  clickhouse-client \
    --user bigdata \
    --password bigdata \
    --query "INSERT INTO mock_data FORMAT CSVWithNames" \
    --input_format_csv_empty_as_default=1 \
    < "$file"
done
