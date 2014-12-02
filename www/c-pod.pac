/* This file is a sample. To make site customizations copy this
 * to 'cpod.pac' which is gitignored.
 * Configure this in your Browser Network preferences to obtain
 * access to webservers within a C-Pod
 * Note:
 *  SOCKS5 works for Chrome (with FoxyProxy) and Firefox
 *  SOCKS fallback works for Safari (tested under Mavericks)
 */
function FindProxyForURL(url, host) {

  if (dnsDomainIs(host, ".local")) {
    return "SOCKS5 <!--#echo var="SERVER_NAME" -->:1080 ; SOCKS <!--#echo var="SERVER_NAME" -->:1080 ";
  }
  return "DIRECT";
}
