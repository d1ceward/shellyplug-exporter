require "../../../spec_helper"

alias DigestAuthHelper = ShellyplugExporter::Gen::Helper::DigestAuthHelper

WWW_AUTHENTICATE = %(Digest qop="auth", realm="shellyplusplugs-aabbccddeeff", ) +
                   %(nonce="6a1e2f3c", algorithm=SHA-256)

describe DigestAuthHelper do
  describe ".ha1" do
    it "hashes username, realm and password" do
      DigestAuthHelper.ha1("admin", "shelly", "secret")
                      .should eq(Digest::SHA256.hexdigest("admin:shelly:secret"))
    end
  end

  describe ".parse_www_authenticate" do
    it "extracts quoted and unquoted parameters" do
      params = DigestAuthHelper.parse_www_authenticate(WWW_AUTHENTICATE)

      params["qop"].should eq("auth")
      params["realm"].should eq("shellyplusplugs-aabbccddeeff")
      params["nonce"].should eq("6a1e2f3c")
      params["algorithm"].should eq("SHA-256")
    end

    it "handles an unquoted parameter that precedes quoted ones" do
      params = DigestAuthHelper.parse_www_authenticate(
        %(Digest algorithm=SHA-256, realm="shelly", nonce="abc", qop="auth")
      )

      params["algorithm"].should eq("SHA-256")
      params["realm"].should eq("shelly")
      params["nonce"].should eq("abc")
      params["qop"].should eq("auth")
    end
  end

  describe ".digest_authorization" do
    it "builds a header whose response digest matches RFC 7616 for SHA-256" do
      header = DigestAuthHelper.digest_authorization(
        "admin",
        "secret",
        "GET",
        "/rpc/Shelly.GetStatus",
        WWW_AUTHENTICATE
      )

      params = DigestAuthHelper.parse_www_authenticate(header)
      params["username"].should eq("admin")
      params["uri"].should eq("/rpc/Shelly.GetStatus")
      params["nc"].should eq("00000001")

      ha1 = Digest::SHA256.hexdigest("admin:shellyplusplugs-aabbccddeeff:secret")
      ha2 = Digest::SHA256.hexdigest("GET:/rpc/Shelly.GetStatus")
      expected = Digest::SHA256.hexdigest(
        [ha1, "6a1e2f3c", "00000001", params["cnonce"], "auth", ha2].join(":")
      )

      params["response"].should eq(expected)
    end

    it "uses the first scheme when the server advertises several qop values" do
      header = DigestAuthHelper.digest_authorization(
        "a", "b", "GET", "/x", %(Digest realm="r", nonce="n", qop="auth,auth-int")
      )

      header.should contain("qop=auth,")
    end

    it "generates a different cnonce on every call" do
      first = DigestAuthHelper.digest_authorization("a", "b", "GET", "/x", WWW_AUTHENTICATE)
      second = DigestAuthHelper.digest_authorization("a", "b", "GET", "/x", WWW_AUTHENTICATE)

      first.should_not eq(second)
    end
  end
end
