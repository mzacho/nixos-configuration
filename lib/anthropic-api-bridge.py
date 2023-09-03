import sys
import json
from anthropic import Anthropic

def create_project(api_key, project_name, description):
    client = Anthropic(api_key=api_key)

    client.messages.create()
    try:
        response = client.messages.create(
            name=project_name,
            description=description
        )
        return json.dumps({"success": True, "project_id": response.id})
    except Exception as e:
        return json.dumps({"success": False, "error": str(e)})

def send_file_to_project(api_key, project_id, file_name, content):
    client = Anthropic(api_key=api_key)
    try:
        response = client.beta.messages.create(
            content_block_params=[
                {
                    "type": "text",
                    "text": content
                }
            ],
            metadata={
                "project_id": project_id,
                "file_name": file_name
            }
        )
        return json.dumps({"success": True, "message_id": response.id})
    except Exception as e:
        return json.dumps({"success": False, "error": str(e)})

def create_chat(api_key, project_id):
    client = Anthropic(api_key=api_key)
    try:
        response = client.beta.messages.create(
            metadata={
                "project_id": project_id
            }
        )
        return json.dumps({"success": True, "chat_id": response.id})
    except Exception as e:
        return json.dumps({"success": False, "error": str(e)})

def send_message(api_key, chat_id, prompt):
    client = Anthropic(api_key=api_key)
    try:
        response = client.messages.create(
            model="claude-3-opus-20240229",
            max_tokens=1024,
            messages=[
                {"role": "user", "content": prompt}
            ],
            metadata={
                "chat_id": chat_id
            }
        )
        return json.dumps({"success": True, "response": response.content[0].text})
    except Exception as e:
        return json.dumps({"success": False, "error": str(e)})

if __name__ == "__main__":
    api_key = sys.argv[1]
    command = sys.argv[2]
    
    if command == "create_project":
        project_name = sys.argv[3]
        description = sys.argv[4]
        print(create_project(api_key, project_name, description))
    elif command == "send_file":
        project_id = sys.argv[3]
        file_name = sys.argv[4]
        content = sys.argv[5]
        print(send_file_to_project(api_key, project_id, file_name, content))
    elif command == "create_chat":
        project_id = sys.argv[3]
        print(create_chat(api_key, project_id))
    elif command == "send_message":
        chat_id = sys.argv[3]
        prompt = sys.argv[4]
        print(send_message(api_key, chat_id, prompt))
    else:
        print(json.dumps({"success": False, "error": "Unknown command"}))
