require_relative 'base'

class Setup
  include Base

  attr_reader :token

  def initialize
    @token = ARGV[0]
  end

  def setup
    save_token
    output_json
  end

  private

  def save_token
    file_path = "#{Base.dir_path}/settings.yml"
    FileUtils.touch(file_path) unless File.exist?(file_path)
    config = YAML.load_file(file_path) || {}

    config['access_token'] = token
    File.open(file_path, 'w') { |f| YAML.dump(config, f) }
  end

  def output_json
    Base.workflow.result
        .title(token)
        .subtitle('Set Papertrail API key')
        .type('default')
        .valid(true)
        .icon('img/icon.png')
        .arg('')

    print Base.workflow.output
  end
end

Setup.new.setup
