# lambda/ecs_deploy.py
import boto3
import os

ecs = boto3.client("ecs")

# Load variables from Lambda environment
CLUSTER_NAME = os.environ["ECS_CLUSTER_NAME"]

# Map ECR repository names to ECS service names
REPO_TO_SERVICE_MAP = {
    os.environ["FRONTEND_REPO_NAME"]: os.environ["FRONTEND_SERVICE_NAME"],
    os.environ["BACKEND_REPO_NAME"]: os.environ["BACKEND_SERVICE_NAME"],
}


def lambda_handler(event, context):
    print(f"Received event: {event}")

    # Extract details from the EventBridge payload
    detail = event.get("detail", {})
    repo_name = detail.get("repository-name")
    image_tag = detail.get("image-tag")

    # Safety check: We only care about the 'latest' tag
    if image_tag != "latest":
        print(f"Ignoring push for tag: {image_tag}")
        return {"status": "ignored", "reason": "Not 'latest' tag"}

    # Find the corresponding ECS service for this ECR repo
    service_name = REPO_TO_SERVICE_MAP.get(repo_name)
    if not service_name:
        print(f"No ECS service mapped for repo: {repo_name}")
        return {"status": "error", "reason": "Unmapped repository"}

    # Trigger the ECS Force Deployment
    print(
        f"Triggering force deployment for service: {service_name} in cluster: {CLUSTER_NAME}"
    )
    try:
        response = ecs.update_service(
            cluster=CLUSTER_NAME, service=service_name, forceNewDeployment=True
        )
        print("Deployment triggered successfully!")
        return {"status": "success", "service": service_name}
    except Exception as e:
        print(f"Error updating service: {str(e)}")
        raise e
