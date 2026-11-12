"""Fusion Proxy residential proxies with httpx (async, several requests in parallel).

export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
"""
import asyncio
import os

import httpx

USER = os.environ["FUSION_USER"]
PASS = os.environ["FUSION_PASS"]
COUNTRY = os.environ.get("FUSION_COUNTRY", "us")
PROXY = f"http://{USER}-country-{COUNTRY}:{PASS}@resi.fusionproxy.net:12286"


async def fetch(client: httpx.AsyncClient, n: int) -> None:
    r = await client.get("https://ipinfo.io/json")
    data = r.json()
    print(f"request {n}: {data['ip']} ({data.get('country')})")


async def main() -> None:
    # every connection through port 12286 gets its own rotating IP
    limits = httpx.Limits(max_keepalive_connections=0)
    async with httpx.AsyncClient(proxy=PROXY, timeout=30, limits=limits) as client:
        await asyncio.gather(*(fetch(client, n) for n in range(1, 6)))


asyncio.run(main())
