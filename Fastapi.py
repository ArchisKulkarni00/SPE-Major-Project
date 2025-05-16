from typing import Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from ollama import Client
from pymilvus import MilvusClient
from utils import load_config, retrieve_context
import requests
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],
)
config = load_config()

# Initialize clients
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "ollama-service")
OLLAMA_PORT = os.getenv("OLLAMA_PORT", "11434")
ollama_url = 'http://{host}:{port}'.format(host=OLLAMA_HOST, port=OLLAMA_PORT)
ollama_client = Client(host=ollama_url)
milvus_client = MilvusClient(config["milvus_path"])

class QueryRequest(BaseModel):
    question: str

@app.post("/ask")
async def ask_question(request: QueryRequest) -> str:
    """Single endpoint RAG query handler"""
    try:
        context = retrieve_context(request.question,
                                   ollama_client,
                                   config["milvus_path"],
                                   config["embedding_model"],
                                   config["collection_name"],
                                   config["top_k"],
                                   config["score_threshold"]) or "No context found"
        
        sys_prompt = config["system_prompt"]
        query = request.question

        prompt = f"""
        Context: {context}
        Question: {query}
        """
            
        jsonPayload = {
                    'model': config["chat_model"],
                    'prompt': prompt,
                    'system': sys_prompt,
                    'stream': False,
                    'options': {
                        'temperature': 0.1
                    }
                }

        response = requests.post(
            url=ollama_url + '/api/generate',
            json= jsonPayload,
        )
        # print(response.json())
        return response.json()['response']
        
    except Exception as e:
        raise HTTPException(500, f"Error processing request: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)