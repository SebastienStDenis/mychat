"use client";
import { useState } from "react";

type ChatMessage = {
  role: string;
  content_type: string;
  content_text: string;
};

const API_PATH = "/api/chat";

export default function Page() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);

  async function sendMessage(e: React.FormEvent) {
    e.preventDefault();
    const text = input.trim();
    if (!text) return;

    const newMessages = [...messages, { role: "user", content_type: "input_text", content_text: text }];
    setMessages(newMessages);
    setInput("");
    setLoading(true);

    try {
      console.log("Sending request to", API_PATH);
      const res = await fetch(API_PATH, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ messages: newMessages }),
      });
      if (res.ok) {
        const data = await res.json();
        setMessages([...newMessages, data as ChatMessage]);
      } else {
        console.error("Chat request failed");
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      <style>{`
        @keyframes blink { 0%{opacity:.2} 20%{opacity:1} 100%{opacity:.2} }
        .loading-dots span { animation: blink 1.4s infinite both; margin-right:.1em; }
        .loading-dots span:nth-child(2){ animation-delay:.2s }
        .loading-dots span:nth-child(3){ animation-delay:.4s }
        input[type="text"], input:not([type]) {
          color: #222;
        }
        @media (prefers-color-scheme: dark) {
          body, html {
            background: #18181b !important;
            color: #f5f5f5 !important;
          }
          .chat-outer {
            background: #18181b !important;
          }
          .chat-inner {
            background: #23272f !important;
            color: #f5f5f5 !important;
            box-shadow: 0 2px 8px rgba(0,0,0,0.4) !important;
          }
          .chat-bubble-assistant {
            background: #192845ff !important;
            color: #f5f5f5 !important;
          }
          .chat-bubble-user {
            background: #64676dff !important;
            color: #fff !important;
          }
          input[type="text"], input:not([type]) {
            background: #23272f !important;
            color: #f5f5f5 !important;
            border: 1px solid #444 !important;
          }
          form {
            background: #23272f !important;
            box-shadow: 0 -2px 8px rgba(0,0,0,0.4) !important;
          }
        }
      `}</style>

      <div className="chat-outer" style={{ background: "#f5f5f5", minHeight: "100vh" }}>
        <div className="chat-inner" style={{ background: "#fff", borderRadius: 8, boxShadow: "0 2px 8px rgba(0,0,0,.05)", padding: "1rem", maxWidth: 600, margin: "0 auto", minHeight: "100vh", display: "flex", flexDirection: "column" }}>
          <div style={{ flex: 1, overflowY: "auto", marginBottom: "5.5rem", display: "flex", flexDirection: "column-reverse" }}>
            {loading && (
              <div style={{ display: "flex", justifyContent: "flex-start", marginBottom: ".5rem" }}>
                <div className="chat-bubble-assistant" style={{ background: "#eee", color: "#222", borderRadius: 16, padding: ".5rem 1rem", maxWidth: "70%", textAlign: "left", display: "inline-block" }}>
                  <strong>assistant:</strong>{" "}
                  <span style={{ display: "inline-block", width: "2.5em" }}>
                    <span className="loading-dots"><span>&bull;</span><span>&bull;</span><span>&bull;</span></span>
                  </span>
                </div>
              </div>
            )}

            {[...messages].reverse().map((m, i) => {
              const isUser = m.role === "user";
              return (
                <div key={i} style={{ marginBottom: ".5rem", display: "flex", justifyContent: isUser ? "flex-end" : "flex-start" }}>
                  <div
                    className={isUser ? "chat-bubble-user" : "chat-bubble-assistant"}
                    style={{
                      background: isUser ? "#6e9eafff" : "#eee",
                      color: isUser ? "#fff" : "#222",
                      borderRadius: 16,
                      padding: ".5rem 1rem",
                      maxWidth: "70%",
                      textAlign: isUser ? "right" : "left",
                    }}
                  >
                    <strong>{isUser ? "You" : m.role}:</strong> {m.content_text}
                  </div>
                </div>
              );
            })}
          </div>

          <form
            onSubmit={sendMessage}
            style={{
              position: "fixed",
              bottom: 0,
              left: 0,
              width: "100vw",
              background: "#fff",
              boxShadow: "0 -2px 8px rgba(0,0,0,.05)",
              padding: "1rem 0",
              display: "flex",
              justifyContent: "center",
              gap: ".5rem",
            }}
          >
            <input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              style={{ width: "60%", padding: ".5rem", borderRadius: 4, border: "1px solid #ccc", background: "#f0f0f0" }}
            />
            <button type="submit" style={{ padding: ".5rem 1rem", borderRadius: 4, background: "#6e9eafff", color: "#fff", border: "none" }}>
              Send
            </button>
          </form>
        </div>
      </div>
    </>
  );
}
