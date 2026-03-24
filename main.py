from fastapi import FastAPI
from pydantic import BaseModel
import anthropic
import os

app = FastAPI()

client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

class Prompt(BaseModel):
  message: str

@app.get("/")
def root():
  return {"status": "AI assistant running"}

@app.post("/chat")
def chat(prompt: Prompt):
  response = client.messages.create(
      model="claude-sonnet-4-6",
      max_tokens=1024,
      messages=[{"role": "user", "content": prompt.message}]
  )
  return {"response": response.content[0].text}
