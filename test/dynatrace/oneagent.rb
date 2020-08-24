module Dynatrace
  class OneAgent
    class S2I
      INCLUDE_FILE = 'dynatrace-monitoring-incl.sh'

      def self.integrate(path, technology = nil)
        integration = "\n"
        integration << "export DT_ONEAGENT_FOR=#{technology}\n" unless technology.nil?
        integration << ". #{Util::S2I::SCRIPTS_PATH}/#{INCLUDE_FILE}\n"

        integration = Regexp.escape(integration).gsub('/') {'\\/'}

        "cp #{ENV['HOME']}/#{INCLUDE_FILE} #{path} && \
         sed -i 's/#!\\/bin\\/bash/&#{integration}/' #{path}/assemble && \
         sed -i 's/exec/#{integration}&/' #{path}/run && \
         sed -i -E 's/exec (.*)/exec \$EXEC_CMD_PREFIX \\1/' #{path}/run"
      end
    end
  end
end