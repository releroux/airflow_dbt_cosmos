import json
import os
import urllib3
from datetime import datetime, timezone

# Environment variables
AIRFLOW_URL = os.environ.get("AIRFLOW_URL")  # e.g., "http://your-ec2-ip:8080"
AIRFLOW_USERNAME = os.environ.get("AIRFLOW_USERNAME", "airflow")
AIRFLOW_PASSWORD = os.environ.get("AIRFLOW_PASSWORD", "airflow")
DAG_NAME = os.environ.get("DAG_NAME")

http = urllib3.PoolManager()


def lambda_handler(event, context):
    print("=" * 50)
    print("Lambda function started")
    print(f"Event received: {json.dumps(event)}")
    print("=" * 50)

    try:
        # Print environment variables (mask password)
        print(f"AIRFLOW_URL: {AIRFLOW_URL}")
        print(f"AIRFLOW_USERNAME: {AIRFLOW_USERNAME}")
        print(f"AIRFLOW_PASSWORD: {'*' * len(AIRFLOW_PASSWORD) if AIRFLOW_PASSWORD else 'None'}")
        print(f"DAG_NAME: {DAG_NAME}")

        # Step 0: Test connection
        health_url = f"{AIRFLOW_URL}/api/v2/monitor/health"
        print(f"\nTesting connection to: {health_url}")
        health_response = http.request("GET", health_url, timeout=10)
        print(f"Health Response Status: {health_response.status}")
        print(f"Health Response: {health_response.data.decode('utf-8')}")

        # Step 1: Get token
        auth_url = f"{AIRFLOW_URL}/auth/token"
        auth_data = {
            "username": AIRFLOW_USERNAME,
            "password": AIRFLOW_PASSWORD
        }
        print(f"\nRequesting token from: {auth_url}")
        
        auth_response = http.request(
            "POST",
            auth_url,
            body=json.dumps(auth_data),
            headers={"Content-Type": "application/json"}
        )
        print(f"Auth Response Status: {auth_response.status}")
        auth_response_data = json.loads(auth_response.data.decode("utf-8"))
        print(f"Auth Response: {json.dumps(auth_response_data, indent=2)}")

        token = auth_response_data["access_token"]
        print("Token obtained successfully")

        # Step 2: Trigger DAG
        trigger_url = f"{AIRFLOW_URL}/api/v2/dags/{DAG_NAME}/dagRuns"
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        trigger_data = {
            "logical_date": datetime.now(timezone.utc).isoformat(),
            "conf": event.get("conf", {})
        }
        
        print(f"\nTriggering DAG at: {trigger_url}")
        print(f"Trigger data: {json.dumps(trigger_data, indent=2)}")

        trigger_response = http.request(
            "POST",
            trigger_url,
            body=json.dumps(trigger_data),
            headers=headers
        )

        print(f"Trigger Response Status: {trigger_response.status}")
        trigger_response_data = json.loads(trigger_response.data.decode("utf-8"))
        print(f"Trigger Response: {json.dumps(trigger_response_data, indent=2)}")

        if trigger_response.status == 200:
            print("\n✅ DAG triggered successfully!")
            return {
                "statusCode": 200,
                "body": json.dumps({
                    "message": "DAG triggered successfully",
                    "dag_name": DAG_NAME,
                    "dag_run_id": trigger_response_data.get("dag_run_id"),
                    "execution_date": trigger_response_data.get("execution_date"),
                    "logical_date": trigger_response_data.get("logical_date"),
                    "state": trigger_response_data.get("state"),
                })
            }
        else:
            print(f"\n❌ Failed to trigger DAG. Status: {trigger_response.status}")
            return {
                "statusCode": trigger_response.status,
                "body": json.dumps({
                    "error": "Failed to trigger DAG",
                    "details": trigger_response_data
                })
            }

    except Exception as e:
        print(f"\n❌ Exception occurred: {type(e).__name__}")
        print(f"Error message: {str(e)}")
        import traceback
        print(f"Traceback:\n{traceback.format_exc()}")

        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": "Failed to trigger DAG",
                "details": str(e)
            })
        }
