require_relative 'base'

# NOTE: using puts/print breaks things
class Search
  include Base

  attr_reader :query

  def initialize
    @query = ARGV.join(' ')
  end

  def search
    load_access_token
    output_json

  rescue => e
    if e.message.include?('No such file or directory @ rb_sysopen')
      setup_json
    else
      raise e
    end
  ensure
    print Base.workflow.output
  end

  private

  def load_access_token
    config = YAML.load_file("#{Base.dir_path}/settings.yml")
    Base.access_token = config['access_token']
  end

  def output_json
    apps = fetch(query)
    return no_match_json if apps.empty?

    apps.each { |app| results_json(app) }
  end

  def fetch(query)
    apps = []
    if File.file?("#{Base.dir_path}/search.yml")
      apps = YAML.load_file("#{Base.dir_path}/search.yml")
    end

    if apps.empty?
      apps = fetch_app_list
    end

    apps.select{|app_name| app_name&.include?(query)}
  end

  def fetch_app_list
    response = HTTParty.get('https://papertrailapp.com/api/v1/systems.json', headers: {
      'X-Papertrail-Token' => Base.access_token
    }).parsed_response

    apps = response.map {|app| app['name']}

    file_path = "#{Base.dir_path}/search.yml"
    FileUtils.touch(file_path) unless File.exist?(file_path)
    File.open(file_path, 'w') { |f| YAML.dump(apps, f) }

    apps
  end

  def results_json(app)
    url = "https://papertrailapp.com/systems/#{app}/events"

    Base.workflow.result
        .uid(app)
        .title(app)
        .subtitle(app)
        .quicklookurl(app)
        .arg(url)
        .text('copy', app)
        .autocomplete(app)
  end

  def no_match_json
    Base.workflow.result
        .title('No matches found!')
        .subtitle('Try a different search term')
        .valid(false)
        .icon('img/icon.png')
  end

  def setup_json
    Base.workflow.result
        .title('Papertrail is not set up yet!')
        .subtitle('Press Enter to find api key, then enter the ptsetup command to save it.')
        .arg('https://papertrailapp.com/account/profile')
        .icon('img/icon.png')
  end
end

Search.new.search
