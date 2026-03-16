# harry-ai backend

thin express proxy so the browser app can actually hit AI endpoints without getting CORS'd to death. groq first, pollinations as fallback. in-memory cache so you're not hammering the same prompt twice.

```
client -> POST /api/text -> groq (fast as hell)
                         -> pollinations (when groq chokes)
```

server-side fetch has no origin. no CORS. no anonymous rate jail. that's the whole point.

---

## setup

```bash
npm install
cp .env.example .env
# throw your groq key in there if you have one
npm run dev
```

hits localhost:3000. frontend auto-connects.

groq key is optional. without it falls back to pollinations which works fine, just slower. with it you get llama 3.1 at ~500ms. get one free at console.groq.com, no CC required.

---

## deploy (railway)

1. push to github
2. railway.app -> new project -> deploy from github repo
3. add env var: `GROQ_API_KEY=gsk_whatever`
4. grab the URL it gives you

then in index.html swap this line:

```js
const BACKEND = window.AIIT_BACKEND || 'http://localhost:3000';
```

to whatever railway gave you. done.

---

## endpoints

```
POST /api/text    {prompt, model, sys, apiKey}   -> {text, cached}
POST /api/audio   {text, voice}                  -> {audio base64, mimeType}
GET  /api/image   ?prompt=&model=&width=&height= -> {url}
GET  /api/models                                 -> [model names]
GET  /                                           -> alive check
```

---

## notes

- cache is in-memory, dies on restart. add redis later if you care
- groq model map is in server.js around line 30, edit as needed
- pollinations fallback uses mistral, change that too if you want
- no auth on the endpoints, don't expose this publicly without adding some
- if you're getting 429s from groq you're probably hammering it, back off

---

## later

- redis for persistent cache across restarts
- rate limiting per IP if you open it up
- supabase for vault sync across devices if you go multi-user
- stripe if you want to charge for it
