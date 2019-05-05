require_relative 'base'

require 'open-uri'

# NOTE: using puts/print breaks things apparently??
module AlfredGenius
  class Search
    include AlfredGenius::Base

    attr_reader :query

    def initialize
      @query = ARGV.join(' ')
    end

    def search
      set_access_token
      output_json

    rescue => e
      # User has not set up token storage
      if e.message.include?('No such file or directory @ rb_sysopen')
        setup_json
      else
        raise e
      end
    ensure
      print Base.workflow.output
    end

    private

    def set_access_token
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
        # print Base.access_token
        # HTTParty.get('https://papertrailapp.com/api/v1/systems.json', headers: {'X-Papertrail-Token' => 'rlFBxGHxmXKrhKbZEML'}).parsed_response
        response = HTTParty.get('https://papertrailapp.com/api/v1/systems.json', headers: {'X-Papertrail-Token' => Base.access_token}).parsed_response

        # response = [{"id"=>1085683671, "name"=>"alerts-service-prod", "last_event_at"=>"2019-05-03T15:53:44-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/alerts-service-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/alerts-service-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1085683671"}}, "ip_address"=>nil, "hostname"=>"alerts-service-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>1085281321, "name"=>"alerts-service-staging", "last_event_at"=>"2019-05-03T15:53:32-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/alerts-service-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/alerts-service-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1085281321"}}, "ip_address"=>nil, "hostname"=>"alerts-service-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}},
        # {"id"=>539078453, "name"=>"amazon-marketplace-direct", "last_event_at"=>"2019-04-27T06:35:41-04:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/amazon-marketplace-direct.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/amazon-marketplace-direct"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=539078453"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs.papertrailapp.com", "port"=>27872}},
        # {"id"=>2812299082, "name"=>"analytics-keyword-service-prod", "last_event_at"=>"2019-05-03T15:53:23-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/analytics-keyword-service-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/analytics-keyword-service-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2812299082"}}, "ip_address"=>nil, "hostname"=>"analytics-keyword-service-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>2811452732, "name"=>"analytics-keyword-service-staging", "last_event_at"=>"2019-05-03T15:53:26-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/analytics-keyword-service-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/analytics-keyword-service-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2811452732"}}, "ip_address"=>nil, "hostname"=>"analytics-keyword-service-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}},
        # {"id"=>3006603901, "name"=>"analytics-reports-api-prod", "last_event_at"=>"2019-05-03T15:53:11-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/analytics-reports-api-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/analytics-reports-api-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=3006603901"}}, "ip_address"=>nil, "hostname"=>"analytics-reports-api-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>2976585231, "name"=>"analytics-reports-api-staging", "last_event_at"=>"2019-05-03T15:08:30-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/analytics-reports-api-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/analytics-reports-api-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2976585231"}}, "ip_address"=>nil, "hostname"=>"analytics-reports-api-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}},
        # {"id"=>2125121062, "name"=>"artifactory-prod", "last_event_at"=>"2019-05-03T15:53:40-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/artifactory-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/artifactory-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2125121062"}}, "ip_address"=>nil, "hostname"=>"artifactory-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>2718766802, "name"=>"artifactory-staging", "last_event_at"=>"2019-05-03T15:53:45-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/artifactory-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/artifactory-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2718766802"}}, "ip_address"=>nil, "hostname"=>"artifactory-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}},
        # {"id"=>1856152351, "name"=>"audits-service-prod", "last_event_at"=>"2019-05-03T15:53:46-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/audits-service-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/audits-service-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1856152351"}}, "ip_address"=>nil, "hostname"=>"audits-service-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>1796367601, "name"=>"audits-service-staging", "last_event_at"=>"2019-05-03T15:53:45-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/audits-service-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/audits-service-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1796367601"}}, "ip_address"=>nil, "hostname"=>"audits-service-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}},
        # {"id"=>301627954, "name"=>"authentication-gateway", "last_event_at"=>"2019-05-03T15:53:30-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/authentication-gateway.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/authentication-gateway"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=301627954"}}, "ip_address"=>nil, "hostname"=>"d.87ccb93e-74a6-498c-8d87-82d73606c835", "syslog"=>{"hostname"=>"logs.papertrailapp.com", "port"=>15283}},
        # {"id"=>1954998781, "name"=>"below-the-fold-prod", "last_event_at"=>"2019-05-03T15:53:16-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/below-the-fold-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/below-the-fold-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1954998781"}}, "ip_address"=>nil, "hostname"=>"below-the-fold-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>1155937341, "name"=>"boomerang", "last_event_at"=>"2019-05-03T09:53:32-04:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/boomerang.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/boomerang"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1155937341"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>46460}},
        # {"id"=>165982313, "name"=>"box-sync", "last_event_at"=>"2019-05-03T15:52:49-04:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/box-sync.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/box-sync"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=165982313"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs3.papertrailapp.com", "port"=>12658}},
        # {"id"=>138258493, "name"=>"box-sync-staging", "last_event_at"=>"2019-02-01T17:57:33-05:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/box-sync-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/box-sync-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=138258493"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs3.papertrailapp.com", "port"=>32239}},
        # {"id"=>2499272472, "name"=>"box-sync-v3", "last_event_at"=>"2019-05-03T15:53:49-04:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/box-sync-v3.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/box-sync-v3"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2499272472"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs7.papertrailapp.com", "port"=>27720}},
        # {"id"=>254403844, "name"=>"boyd-indexer", "last_event_at"=>"2019-05-03T15:53:06-04:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/boyd-indexer.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/boyd-indexer"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=254403844"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs4.papertrailapp.com", "port"=>18611}},
        # {"id"=>2113748562, "name"=>"brand-space-prod", "last_event_at"=>"2019-05-03T15:53:33-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/brand-space-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/brand-space-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2113748562"}}, "ip_address"=>nil, "hostname"=>"brand-space-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>2451530702, "name"=>"brand-space-staging", "last_event_at"=>"2019-05-03T15:53:21-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/brand-space-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/brand-space-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2451530702"}}, "ip_address"=>nil, "hostname"=>"brand-space-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}},
        # {"id"=>268399314, "name"=>"bulk-template", "last_event_at"=>"2018-09-06T18:33:48-04:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/bulk-template.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/bulk-template"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=268399314"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs4.papertrailapp.com", "port"=>39224}},
        # {"id"=>1820968611, "name"=>"burrow-staging", "last_event_at"=>"2019-05-03T15:53:11-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/burrow-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/burrow-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1820968611"}}, "ip_address"=>nil, "hostname"=>"burrow-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}},
        # {"id"=>1852449451, "name"=>"buybox-reporting-engine-prod", "last_event_at"=>"2019-05-03T15:53:36-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/buybox-reporting-engine-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/buybox-reporting-engine-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1852449451"}}, "ip_address"=>nil, "hostname"=>"buybox-reporting-engine-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>1832570051, "name"=>"buybox-reporting-engine-staging", "last_event_at"=>"2019-05-03T15:53:36-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/buybox-reporting-engine-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/buybox-reporting-engine-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1832570051"}}, "ip_address"=>nil, "hostname"=>"buybox-reporting-engine-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}},
        # {"id"=>1034254381, "name"=>"canary-org", "last_event_at"=>"2019-05-03T14:18:49-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/canary-org.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/canary-org"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1034254381"}}, "ip_address"=>nil, "hostname"=>"d.843d8235-0a75-4a8f-a190-125bbd3900e9", "syslog"=>{"hostname"=>"logs.papertrailapp.com", "port"=>15283}},
        # {"id"=>2194552761, "name"=>"cascade", "last_event_at"=>"2019-05-03T15:53:40-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/cascade.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/cascade"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2194552761"}}, "ip_address"=>nil, "hostname"=>"d.0f62891f-fd4a-4f0f-b915-6b0f09ecdf6f", "syslog"=>{"hostname"=>"logs.papertrailapp.com", "port"=>15283}},
        # {"id"=>2225943262, "name"=>"cascade-old", "last_event_at"=>"2019-02-25T12:47:07-05:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/cascade-old.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/cascade-old"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2225943262"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs7.papertrailapp.com", "port"=>14206}},
        # {"id"=>611455902, "name"=>"catalog-auth", "last_event_at"=>"2019-05-03T15:52:47-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/catalog-auth.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/catalog-auth"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=611455902"}}, "ip_address"=>nil, "hostname"=>"d.7b932da1-7b2b-4eb9-9c15-6ef806deaf6e", "syslog"=>{"hostname"=>"logs.papertrailapp.com", "port"=>15283}},
        # {"id"=>3034087661, "name"=>"catalog-google-oauth", "last_event_at"=>"2019-05-03T15:29:04-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/catalog-google-oauth.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/catalog-google-oauth"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=3034087661"}}, "ip_address"=>nil, "hostname"=>"d.79f053b9-c111-497f-af5c-92af7dac6bb8", "syslog"=>{"hostname"=>"logs.papertrailapp.com", "port"=>15283}},
        # {"id"=>1665339861, "name"=>"channelcast", "last_event_at"=>"2019-05-03T15:53:37-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/channelcast.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/channelcast"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=1665339861"}}, "ip_address"=>nil, "hostname"=>"d.35578fa6-5342-45bc-9386-5c7a83c28f34", "syslog"=>{"hostname"=>"logs.papertrailapp.com", "port"=>15283}},
        # {"id"=>848557141, "name"=>"charlie-work", "last_event_at"=>"2019-05-03T15:53:49-04:00", "auto_delete"=>false, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/charlie-work.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/charlie-work"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=848557141"}}, "ip_address"=>nil, "hostname"=>nil, "syslog"=>{"hostname"=>"logs5.papertrailapp.com", "port"=>35336}},
        # {"id"=>2842599752, "name"=>"chat-transcript-service-prod", "last_event_at"=>"2019-05-03T14:12:49-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/chat-transcript-service-prod.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/chat-transcript-service-prod"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2842599752"}}, "ip_address"=>nil, "hostname"=>"chat-transcript-service-prod", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>28111}},
        # {"id"=>2820566792, "name"=>"chat-transcript-service-staging", "last_event_at"=>"2019-05-03T15:53:04-04:00", "auto_delete"=>true, "_links"=>{"self"=>{"href"=>"https://papertrailapp.com/api/v1/systems/chat-transcript-service-staging.json"}, "html"=>{"href"=>"https://papertrailapp.com/systems/chat-transcript-service-staging"}, "search"=>{"href"=>"https://papertrailapp.com/api/v1/events/search.json?system_id=2820566792"}}, "ip_address"=>nil, "hostname"=>"chat-transcript-service-staging", "syslog"=>{"hostname"=>"logs6.papertrailapp.com", "port"=>50437}}]

        apps = response.map {|app| app['name']}

        file_path = "#{Base.dir_path}/search.yml"
        # puts file_path
        FileUtils.touch(file_path) unless File.exist?(file_path)
        config = YAML.load_file(file_path) || []

        config.concat(apps)
        File.open(file_path, 'w') { |f| YAML.dump(config, f) }
      end

      apps.select{|app_name| app_name&.include?(query)}
    end

    def results_json(app)
      pt_url = "https://papertrailapp.com/systems/#{app}/events"

      Base.workflow.result
          .uid(app)
          .title(app)
          .subtitle(app)
          .quicklookurl(app)
          .arg(pt_url)
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
end

AlfredGenius::Search.new.search
