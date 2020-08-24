module Util
  class Docker
    def self.build(path, tag)
      "docker build -t #{tag} #{path}"
    end

    def self.exec(name, cmd)
      "docker exec #{name} #{cmd}"
    end

    def self.run(image, options = '', cmd = nil, name = nil)
      options << " --name #{name}" unless name.nil?

      result = ''
      if cmd.nil?
        result = "id=\`docker run --detach -P #{options} #{image}\` && \
                  sleep 20 && \
                  docker logs \$id"
      else
        result = "docker run #{options} #{image} #{cmd}"
      end

      return result
    end
  end
end