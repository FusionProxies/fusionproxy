// Fusion Proxy residential proxies with axios.
// export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
import axios from 'axios';
import { HttpsProxyAgent } from 'https-proxy-agent';

const { FUSION_USER, FUSION_PASS, FUSION_COUNTRY = 'us' } = process.env;
if (!FUSION_USER || !FUSION_PASS) throw new Error('set FUSION_USER and FUSION_PASS');

const user = encodeURIComponent(`${FUSION_USER}-country-${FUSION_COUNTRY}`);
const agent = new HttpsProxyAgent(`http://${user}:${encodeURIComponent(FUSION_PASS)}@resi.fusionproxy.net:12286`);

// proxy: false stops axios from applying its own proxy handling on top of the agent
const { data } = await axios.get('https://ipinfo.io/json', { httpsAgent: agent, proxy: false, timeout: 30000 });
console.log(`${data.ip} (${data.country}, ${data.city})`);
