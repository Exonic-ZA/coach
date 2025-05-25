#!/usr/bin/env python3

import subprocess
import boto3
import sys
import json
import base64
import os

# === CONFIGURATION ===
AWS_REGION = os.getenv("AWS_REGION", "af-south-1")
ACCOUNT_ID = os.getenv("AWS_ACCOUNT_ID")
REPO_NAME = os.getenv("ECR_REPO_NAME")
VERSION_FILE = "version.json"

def run(command: list, **kwargs):
    print(f"💻 Running: {' '.join(command)}")
    subprocess.run(command, check=True, **kwargs)

def get_version():
    try:
        with open(VERSION_FILE, "r") as f:
            return json.load(f)["version"]
    except (FileNotFoundError, KeyError, json.JSONDecodeError) as e:
        print(f"❌ Failed to load version: {e}")
        sys.exit(1)

def docker_login_ecr():
    print("🔐 Logging into ECR...")
    ecr = boto3.client("ecr", region_name=AWS_REGION)
    token = ecr.get_authorization_token()
    auth_data = token["authorizationData"][0]
    ecr_url = auth_data["proxyEndpoint"]
    decoded_token = base64.b64decode(auth_data["authorizationToken"]).decode("utf-8")
    username, password = decoded_token.split(":")
    run(["docker", "login", "--username", username, "--password", password, ecr_url])
    return ecr_url

def main():
    version = get_version()
    ecr_url = f"{ACCOUNT_ID}.dkr.ecr.{AWS_REGION}.amazonaws.com/{REPO_NAME}"
    image_latest = f"{ecr_url}:latest"
    image_version = f"{ecr_url}:v{version}"

    docker_login_ecr()

    print(f"🛠 Creating Buildx builder...")
    try:
        run(["docker", "buildx", "create", "--use"])
    except subprocess.CalledProcessError:
        print("⚠️ Buildx builder already exists or failed to create (this is usually okay)")

    print(f"📦 Building multi-arch Docker image (v{version})...")
    run([
        "docker", "buildx", "build",
        "--platform", "linux/amd64,linux/arm64",
        "--tag", image_latest,
        "--tag", image_version,
        "--push",
        "."
    ])

    print(f"✅ Done! Image pushed as:\n- {image_latest}\n- {image_version}")

if __name__ == "__main__":
    main()