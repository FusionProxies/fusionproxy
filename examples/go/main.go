// Fusion Proxy residential proxies with Go net/http.
// export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"net/url"
	"os"
	"time"
)

func client(options string) *http.Client {
	proxyURL := &url.URL{
		Scheme: "http",
		User:   url.UserPassword(os.Getenv("FUSION_USER")+options, os.Getenv("FUSION_PASS")),
		Host:   "resi.fusionproxy.net:12286",
	}
	return &http.Client{
		Transport: &http.Transport{Proxy: http.ProxyURL(proxyURL)},
		Timeout:   30 * time.Second,
	}
}

func exitIP(c *http.Client) string {
	resp, err := c.Get("https://ipinfo.io/json")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()
	var data struct{ IP, Country, City string }
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		log.Fatal(err)
	}
	return fmt.Sprintf("%s (%s, %s)", data.IP, data.Country, data.City)
}

func main() {
	if os.Getenv("FUSION_USER") == "" || os.Getenv("FUSION_PASS") == "" {
		log.Fatal("set FUSION_USER and FUSION_PASS")
	}
	country := os.Getenv("FUSION_COUNTRY")
	if country == "" {
		country = "us"
	}

	// rotating: a new IP on every request
	fmt.Println("rotating:", exitIP(client("-country-"+country)))

	// sticky: the same session ID keeps the same IP for 10 minutes
	sticky := client(fmt.Sprintf("-country-%s-sessid-%d-sessTime-600s", country, 1000000+rand.Intn(9000000)))
	fmt.Println("sticky:  ", exitIP(sticky))
	fmt.Println("sticky:  ", exitIP(sticky))
}
