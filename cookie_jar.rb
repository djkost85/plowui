# Parses a CURL cookie JAR file and extracts
# all cookies contained in it.
# Does not care for domains, thus more cookies than
# necessary might be returned.
class CookieJar

  # Parses the given cookie jar content and returns
  # an array of strings of the form name=value.
  # These can be sent as
  #
  #   Cookie: name=value; name2=value2
  #
  # headers by a download application.
  def to_headers(content)
    lines = content.split(/\n/).map(&:strip)
    cookie_lines = lines.reject do |line|
      line =~ /^\s*$/ or line =~ /^#\s/
    end
    return cookie_lines.map do |line|
      parts = line.split(/\t/)
      "#{parts[5]}=#{parts[6]}"
    end
  end

end

