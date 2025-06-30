from flask import Flask, request, jsonify
import boto3
import os
import uuid

app = Flask(__name__)

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb', region_name=os.environ.get("AWS_REGION", "ap-south-1"))
table = dynamodb.Table(os.environ.get("DYNAMODB_TABLE", "TaskManager"))

@app.route("/tasks", methods=["POST"])
def create_task():
    data = request.get_json()
    task_id = str(uuid.uuid4())
    item = {
        "task_id": task_id,
        "title": data.get("title", "Untitled Task"),
        "status": data.get("status", "pending")
    }
    table.put_item(Item=item)
    return jsonify(item), 201

@app.route("/tasks", methods=["GET"])
def get_tasks():
    response = table.scan()
    return jsonify(response.get("Items", [])), 200

@app.route("/tasks/<task_id>", methods=["DELETE"])
def delete_task(task_id):
    table.delete_item(Key={"task_id": task_id})
    return jsonify({"message": f"Task {task_id} deleted."}), 200
