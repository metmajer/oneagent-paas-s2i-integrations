module Util
  class S2I
    SCRIPTS_PATH = '/usr/libexec/s2i'

    def self.build(image, source, tag, flags = '')
      "s2i build #{source} #{image} #{tag} #{flags}"
    end
  end
end