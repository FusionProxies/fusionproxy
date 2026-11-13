<p align="center">
  <a href="https://fusionproxy.net/?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/FusionProxies/.github/main/assets/logo-on-dark.png">
      <img src="https://raw.githubusercontent.com/FusionProxies/.github/main/assets/logo-on-light.png" alt="Fusion Proxy" height="52">
    </picture>
  </a>
</p>

# Fusion Proxy: residential proxy code examples

How to connect to [Fusion Proxy](https://fusionproxy.net/?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy) residential proxies, with working examples in cURL, Python, Node.js, Go, PHP, Java, C# and Ruby. Every example reads your credentials from environment variables and prints the exit IP and country it got.

## Contents

- [How it works](#how-it-works)
- [Endpoints](#endpoints)
- [Username options](#username-options)
- [Rotating or sticky](#rotating-or-sticky)
- [Examples](#examples)
- [Common errors](#common-errors)
- [Links](#links)

## How it works

1. [Create an account](https://dashboard.fusionproxy.net/#/register?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy) and add residential traffic. Traffic never expires.
2. Copy your proxy username and password from the dashboard (or create a sub-user).
3. Send requests through `resi.fusionproxy.net`. Location and session options go into the username, so one endpoint covers every country.

## Endpoints

| Protocol | Host | Port | Behaviour |
|---|---|---|---|
| HTTP / HTTPS | `resi.fusionproxy.net` | `12286` | New IP on every request, unless the username asks for a sticky session |
| HTTP / HTTPS | `resi.fusionproxy.net` | `13000` to `15000` | Each port keeps its own IP for up to 1 hour, so several ports give you several IPs at once |
| SOCKS5 | `resi.fusionproxy.net` | `5390` | Same username options as HTTP |

Use `socks5h://` (not `socks5://`) in clients that support it, so DNS is resolved on the proxy side and the target sees the exit location, not yours.

## Username options

Options are appended to your username with hyphens, in this order:

```
USERNAME-country-us-state-ca-city-losangeles-sessid-4821937-sessTime-600s
```

| Option | Example | Meaning |
|---|---|---|
| `-country-XX` | `-country-de` | Exit country, two-letter ISO code |
| `-state-XX` | `-state-ca` | State or region code, where the country has them in stock |
| `-city-CODE` | `-city-losangeles` | City code, as listed in the endpoint generator |
| `-sessid-ID` | `-sessid-4821937` | Session ID: the same ID keeps the same IP |
| `-sessTime-Ns` | `-sessTime-600s` | How long a session holds its IP, 1 to 120 minutes, in seconds |

The [endpoint generator](https://fusionproxy.net/guides/endpoint-generator?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy) in the dashboard builds these usernames for you and lists the states and cities in stock.

> Do not use a hyphen inside a sub-user name. Everything after the first hyphen is read as options, so `team-alpha` is read as `team` plus an unknown option and the proxy answers `407`.

## Rotating or sticky

- **Rotating** (no `-sessid-`): every request on port `12286` gets a new residential IP. Good for scraping many pages.
- **Sticky** (`-sessid-` and `-sessTime-`): requests with the same session ID keep one IP for the time you set. Good for logins, carts and multi-step flows. Change the ID to get a new IP.

A residential IP belongs to a real device, so it can still change before the session ends if that device goes offline.

## Examples

Set your credentials once:

```bash
export FUSION_USER="your_username"
export FUSION_PASS="your_password"
export FUSION_COUNTRY="us"   # optional
```

| Language | File | Run |
|---|---|---|
| cURL | [examples/curl/examples.sh](examples/curl/examples.sh) | `bash examples/curl/examples.sh` |
| Python (requests) | [examples/python/requests_example.py](examples/python/requests_example.py) | `pip install -r examples/python/requirements.txt` then `python examples/python/requests_example.py` |
| Python (httpx, async) | [examples/python/httpx_async_example.py](examples/python/httpx_async_example.py) | `python examples/python/httpx_async_example.py` |
| Node.js (fetch) | [examples/node/fetch_example.mjs](examples/node/fetch_example.mjs) | `cd examples/node && npm install && node fetch_example.mjs` |
| Node.js (axios) | [examples/node/axios_example.mjs](examples/node/axios_example.mjs) | `node axios_example.mjs` |
| Go | [examples/go/main.go](examples/go/main.go) | `cd examples/go && go run .` |
| PHP | [examples/php/example.php](examples/php/example.php) | `php examples/php/example.php` |
| Java 11+ | [examples/java/ProxyExample.java](examples/java/ProxyExample.java) | `java -Djdk.http.auth.tunneling.disabledSchemes= examples/java/ProxyExample.java` |
| C# (.NET 8) | [examples/csharp/Program.cs](examples/csharp/Program.cs) | `cd examples/csharp && dotnet run` |
| Ruby | [examples/ruby/example.rb](examples/ruby/example.rb) | `ruby examples/ruby/example.rb` |

The shortest version, in Python:

```python
import os, requests

user = f"{os.environ['FUSION_USER']}-country-us"
proxy = f"http://{user}:{os.environ['FUSION_PASS']}@resi.fusionproxy.net:12286"

r = requests.get("https://ipinfo.io/json", proxies={"http": proxy, "https": proxy}, timeout=30)
print(r.json()["ip"], r.json()["country"])
```

Browser automation has its own repositories: [playwright-proxy](https://github.com/FusionProxies/playwright-proxy), [puppeteer-proxy](https://github.com/FusionProxies/puppeteer-proxy) and [selenium-proxy](https://github.com/FusionProxies/selenium-proxy). For Scrapy there is [scrapy-proxy-middleware](https://github.com/FusionProxies/scrapy-proxy-middleware), and AI agents can use the [MCP server](https://github.com/FusionProxies/fusionproxy-mcp).

Step-by-step guides: [Python requests](https://github.com/FusionProxies/python-requests-proxy), [retries](https://github.com/FusionProxies/python-requests-retry), [web scraping with Python](https://github.com/FusionProxies/python-web-scraping), [Node.js](https://github.com/FusionProxies/nodejs-proxy) and [cURL](https://github.com/FusionProxies/curl-proxy).

## Common errors

| Error | Usual cause |
|---|---|
| `407 Proxy Authentication Required` | Wrong username or password, a hyphen inside a sub-user name, or a misspelled option |
| Exit IP in the wrong country | The option is missing from the username, or the client sends DNS locally (use `socks5h://`) |
| Timeouts on one site only | The site is slow or blocks the request; try another session ID or country |

To check a proxy from the browser, use the free [proxy checker](https://fusionproxy.net/tools/proxy-checker?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy) and [what is my IP](https://fusionproxy.net/tools/my-ip?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy) tools.

## Links

- [Quick start guide](https://fusionproxy.net/guides/quick-start?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy)
- [All guides](https://fusionproxy.net/guides?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy)
- [Pricing](https://fusionproxy.net/pricing?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy)
- [Free trial](https://fusionproxy.net/free-trial?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy)
- [Contact](https://fusionproxy.net/contact?utm_source=github&utm_medium=referral&utm_campaign=fusionproxy)

## License

MIT, see [LICENSE](LICENSE).
