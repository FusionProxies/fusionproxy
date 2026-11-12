"""Fusion Proxy residential proxies with Python requests.

export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
"""
import os
import random

import requests

USER = os.environ["FUSION_USER"]
PASS = os.environ["FUSION_PASS"]
COUNTRY = os.environ.get("FUSION_COUNTRY", "us")
HOST = "resi.fusionproxy.net"


def proxy(options: str = "", port: int = 12286) -> dict:
    url = f"http://{USER}{options}:{PASS}@{HOST}:{port}"
    return {"http": url, "https": url}


def exit_ip(proxies: dict) -> str:
    r = requests.get("https://ipinfo.io/json", proxies=proxies, timeout=30)
    r.raise_for_status()
    data = r.json()
    return f"{data['ip']} ({data.get('country')}, {data.get('city')})"


# 1. rotating: a new IP on every request
print("rotating:", exit_ip(proxy(f"-country-{COUNTRY}")))
print("rotating:", exit_ip(proxy(f"-country-{COUNTRY}")))

# 2. sticky: the same session ID keeps the same IP for 10 minutes
sticky = proxy(f"-country-{COUNTRY}-sessid-{random.randint(1000000, 9999999)}-sessTime-600s")
print("sticky:  ", exit_ip(sticky))
print("sticky:  ", exit_ip(sticky))
