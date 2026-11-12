<?php
// Fusion Proxy residential proxies with PHP cURL.
// export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]

$user = getenv('FUSION_USER') ?: exit("set FUSION_USER and FUSION_PASS\n");
$pass = getenv('FUSION_PASS') ?: exit("set FUSION_USER and FUSION_PASS\n");
$country = getenv('FUSION_COUNTRY') ?: 'us';

function exitIp(string $proxyUser, string $pass): string
{
    $ch = curl_init('https://ipinfo.io/json');
    curl_setopt_array($ch, [
        CURLOPT_PROXY => 'http://resi.fusionproxy.net:12286',
        CURLOPT_PROXYUSERPWD => $proxyUser . ':' . $pass,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30,
    ]);
    $body = curl_exec($ch);
    if ($body === false) {
        throw new RuntimeException(curl_error($ch));
    }
    curl_close($ch);
    $data = json_decode($body, true);
    return "{$data['ip']} ({$data['country']}, {$data['city']})";
}

// rotating: a new IP on every request
echo 'rotating: ', exitIp("$user-country-$country", $pass), PHP_EOL;

// sticky: the same session ID keeps the same IP for 10 minutes
$sticky = "$user-country-$country-sessid-" . random_int(1000000, 9999999) . '-sessTime-600s';
echo 'sticky:   ', exitIp($sticky, $pass), PHP_EOL;
echo 'sticky:   ', exitIp($sticky, $pass), PHP_EOL;
