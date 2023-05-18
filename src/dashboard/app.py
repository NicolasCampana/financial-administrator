import os
from functools import cache

from fastapi import FastAPI
from redis import Redis, RedisError

app = FastAPI()


@app.get("/transaction/{t_id}")
async def get_transaction(t_id: str):
    return {"item_id": t_id}


@app.get("/")
async def index():
    try:
        page_views = redis().incr("page_views")
    except RedisError:
        return "Sorry, something went wrong."
    else:
        return {"message": f"Number of Page views {page_views}"}


@cache
def redis():
    return Redis.from_url(os.getenv("REDIS_URL", "redis://localhost:6379"))
