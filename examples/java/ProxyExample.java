// Fusion Proxy residential proxies with Java 11+ HttpClient.
// export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
// Run with: java -Djdk.http.auth.tunneling.disabledSchemes= ProxyExample.java
// (Java blocks Basic auth for HTTPS tunnels by default; the flag allows it.)
import java.net.Authenticator;
import java.net.InetSocketAddress;
import java.net.PasswordAuthentication;
import java.net.ProxySelector;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

public class ProxyExample {
    public static void main(String[] args) throws Exception {
        // same as the -D flag above, for runs without it (must happen before the first request)
        System.setProperty("jdk.http.auth.tunneling.disabledSchemes", "");

        String user = System.getenv("FUSION_USER");
        String pass = System.getenv("FUSION_PASS");
        String country = System.getenv().getOrDefault("FUSION_COUNTRY", "us");
        if (user == null || pass == null) throw new IllegalStateException("set FUSION_USER and FUSION_PASS");
        String proxyUser = user + "-country-" + country;

        HttpClient client = HttpClient.newBuilder()
                .proxy(ProxySelector.of(new InetSocketAddress("resi.fusionproxy.net", 12286)))
                .authenticator(new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(proxyUser, pass.toCharArray());
                    }
                })
                .connectTimeout(Duration.ofSeconds(30))
                .build();

        HttpRequest request = HttpRequest.newBuilder(URI.create("https://ipinfo.io/json")).build();
        System.out.println(client.send(request, HttpResponse.BodyHandlers.ofString()).body());
    }
}
