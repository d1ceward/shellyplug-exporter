module ShellyplugExporter::Gen::Helper
  module DigestAuthHelper
    def self.ha1(username : String, realm : String, password : String) : String
      Digest::SHA256.hexdigest("#{username}:#{realm}:#{password}")
    end

    def self.parse_www_authenticate(header : String) : Hash(String, String)
      params = {} of String => String
      header.scan(/(\w+)="?([^"]+)"?/) do |match|
        params[match[1]] = match[2]
      end

      params
    end

    def self.digest_authorization(
      username : String,
      password : String,
      method : String,
      uri : String,
      www_auth : String
    ) : String
      params = parse_www_authenticate(www_auth)
      realm = params["realm"]
      nonce = params["nonce"]
      qop = params["qop"]? || "auth"
      algorithm = params["algorithm"]? || "SHA-256"
      nc = "00000001"
      cnonce = Random::Secure.hex(8)

      ha1 = ha1(username, realm, password)
      ha2 = Digest::SHA256.hexdigest("#{method}:#{uri}")
      response = Digest::SHA256.hexdigest([ha1, nonce, nc, cnonce, qop, ha2].join(":"))

      [
        "Digest username=\"#{username}\"",
        "realm=\"#{realm}\"",
        "nonce=\"#{nonce}\"",
        "uri=\"#{uri}\"",
        "algorithm=#{algorithm}",
        "response=\"#{response}\"",
        "qop=#{qop}",
        "nc=#{nc}",
        "cnonce=\"#{cnonce}\""
      ].join(", ")
    end
  end
end
