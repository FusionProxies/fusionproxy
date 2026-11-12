// Fusion Proxy residential proxies with fetch (undici ProxyAgent).
// export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
import { fetch, ProxyAgent } from 'undici';

const { FUSION_USER, FUSION_PASS, FUSION_COUNTRY = 'us' } = process.env;
if (!FUSION_USER || !FUSION_PASS) throw new Error('set FUSION_USER and FUSION_PASS');

const agent = (options) => new ProxyAgent({
  uri: 'http://resi.fusionproxy.net:12286',
  token: 'Basic ' + Buffer.from(`${FUSION_USER}${options}:${FUSION_PASS}`).toString('base64'),
});

const exitIp = async (dispatcher) => {
  const data = await (await fetch('https://ipinfo.io/json', { dispatcher })).json();
  return `${data.ip} (${data.country}, ${data.city})`;
};

// rotating: a new IP on every request
console.log('rotating:', await exitIp(agent(`-country-${FUSION_COUNTRY}`)));

// sticky: the same session ID keeps the same IP for 10 minutes
const sticky = agent(`-country-${FUSION_COUNTRY}-sessid-${Math.floor(Math.random() * 9e6) + 1e6}-sessTime-600s`);
console.log('sticky:  ', await exitIp(sticky));
console.log('sticky:  ', await exitIp(sticky));
