# serverless-task-manager

✅ Project Stack
Component	    Tech
Backend	        Flask (Python)
Hosting	        AWS Lambda (serverless compute)
API Gateway	    AWS API Gateway
Storage	        DynamoDB (task list)
Infra	        Terraform
CI/CD	        Jenkins
SCM	            GitHub


🧱 High-Level Architecture

Client → API Gateway → Lambda (Flask App via Mangum) → DynamoDB
                            ↑
                    Deployed by Terraform
                    Triggered by Jenkins

🗂️ Project Folder Structure

serverless-task-manager/
├── app/
│   ├── app.py                # Flask app with task routes
│   └── wsgi_handler.py       # Entry point for Lambda (using Mangum)
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── requirements.txt
├── Jenkinsfile
└── README.md

 Core Features
POST /tasks → Add a task

GET /tasks → Get list of tasks

DELETE /tasks/<id> → Delete a task

🔧 Stack Setup Phases
Phase 1: 
Build Flask App
 app.py for basic task CRUD

 wsgi_handler.py using Mangum

Phase 2: 
Terraform for Infra
 Provision Lambda function

 Set up API Gateway

 Create DynamoDB table

 IAM roles & permissions

Phase 3: 
Prepare App for Lambda
 Install dependencies

 Zip code + deploy with Terraform

Phase 4: 
Jenkins CI/CD
 On push, Jenkins:

Builds zip

Uploads to S3

Runs terraform apply

✅ Step 1: app/app.py – Flask Task Manager API
✅ Step 2: wsgi_handler.py – Adapter for AWS Lambda (using Mangum)
✅ Step 3: requirements.txt
✅ Step 4: Local Folder Structure
✅ Next Step: Packaging & Zipping
    # Step into project root
    mkdir -p package
    pip install -r requirements.txt -t package/
    cp -r app/ wsgi_handler.py package/
    cd package
    zip -r ../app.zip .