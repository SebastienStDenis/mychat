from fastapi import FastAPI, APIRouter
from pydantic import BaseModel
from openai import OpenAI
from openai.types.responses import ResponseInputItemParam
from typing import cast
import os

app = FastAPI()

api_router = APIRouter(prefix="/api", tags=["API Endpoints"])


class ChatMessage(BaseModel):
    role: str
    content_type: str
    content_text: str


class ChatRequest(BaseModel):
    messages: list[ChatMessage]


OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-5-nano")

if (not OPENAI_API_KEY) or (not OPENAI_MODEL):
    raise ValueError(
        "OPENAI_API_KEY and OPENAI_MODEL must be set in environment variables"
    )

client = OpenAI(api_key=OPENAI_API_KEY)


@api_router.post("/chat", response_model=ChatMessage)
async def chat(req: ChatRequest) -> ChatMessage:
    inputs: list[ResponseInputItemParam] = [
        cast(
            ResponseInputItemParam,
            {
                "role": m.role,
                "content": [{"type": m.content_type, "text": m.content_text}],
            },
        )
        for m in req.messages
    ]

    response = client.responses.create(
        model=OPENAI_MODEL,
        input=inputs,
    )

    return ChatMessage(
        role="assistant",
        content_type="output_text",
        content_text=response.output_text or "",
    )


@app.get("/healthz")
def health_check() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(api_router)


def main() -> None:
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=3001)


if __name__ == "__main__":
    main()
