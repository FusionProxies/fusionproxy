// Fusion Proxy residential proxies with C# HttpClient.
// export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
using System.Net;

var user = Environment.GetEnvironmentVariable("FUSION_USER") ?? throw new Exception("set FUSION_USER and FUSION_PASS");
var pass = Environment.GetEnvironmentVariable("FUSION_PASS") ?? throw new Exception("set FUSION_USER and FUSION_PASS");
var country = Environment.GetEnvironmentVariable("FUSION_COUNTRY") ?? "us";

var proxy = new WebProxy("http://resi.fusionproxy.net:12286")
{
    Credentials = new NetworkCredential($"{user}-country-{country}", pass),
};

using var client = new HttpClient(new HttpClientHandler { Proxy = proxy, UseProxy = true })
{
    Timeout = TimeSpan.FromSeconds(30),
};

Console.WriteLine(await client.GetStringAsync("https://ipinfo.io/json"));
