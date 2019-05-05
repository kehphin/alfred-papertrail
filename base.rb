require_relative 'lib/alfred-workflow-ruby/alfred-3_workflow'
require_relative 'lib/httparty/httparty'

require 'fileutils'
require 'yaml'

module AlfredGenius
  module Base
    class << self
      attr_reader :workflow, :home_path, :dir_path
      attr_accessor :access_token
      attr_writer   :text_format

      PLAIN_TEXT_FORMAT = "plain".freeze

      def text_format
        @text_format || PLAIN_TEXT_FORMAT
      end
    end

    @workflow  = Alfred3::Workflow.new
    @home_path = ENV['HOME']
    @dir_path  = FileUtils.mkdir_p("#{@home_path}/Library/Application Support/Alfred 3/Workflow Data/app.kevinyang.papertrail.alfredworkflow").first
  end
end
