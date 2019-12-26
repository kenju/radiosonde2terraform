require 'erb'
require 'aws-sdk-cloudwatch'
require 'radiosonde'

module Radiosonde2terraform
  class Resolver
    # @param [Radiosonde2terraform::Optoins] options
    def initialize(options:)
      @options = options
    end
    attr_reader :options

    # @param [String] filepath - a file path to the DSL
    # @return [String] the generated .tf file
    def to_tf_conf(filepath)
      alarms = parse_conf(filepath)
      ERB.new(cloudwatch_alarm_template, trim_mode: '-').result(binding)
    end

    private

    # @param [String] filepath
    # @return [Array<Radiosonde::DSL::Context::Alarm>]
    def parse_conf(filepath)
      dsl = open(filepath) { |f| Radiosonde::DSL.parse(f.read, filepath) }
      dsl.alarms
    end

    def cloudwatch_alarm_template
      <<~TEMPLATE
      <%- alarms.each do |resource| -%>
      resource "aws_cloudwatch_metric_alarm" "<%= resource.alarm_name %>" {
        actions_enabled           = "<%= resource.actions_enabled %>"
        alarm_actions             = <%= resource.alarm_actions %>
        alarm_name                = "<%= resource.alarm_name %>"
        comparison_operator       = "<%= resource.comparison_operator %>"
        alarm_description         = "<%= resource.alarm_description %>"
        dimensions                = {
          <%- resource.dimensions.each do |dimension| -%>
          <%= dimension[:name] %> = "<%= dimension[:value] %>"
          <%- end -%>
        }
        evaluation_periods        = "<%= resource.evaluation_periods %>"
        insufficient_data_actions = <%= resource.insufficient_data_actions %>
        metric_name               = "<%= resource.metric_name %>"
        namespace                 = "<%= resource.namespace %>"
        ok_actions                = <%= resource.ok_actions %>
        period                    = "<%= resource.period %>"
        statistic                 = "<%= resource.statistic %>"
        tags                      = {
          <%- tags = resource.tags || options.default_tags -%>
          <%- tags.each do |tag| -%>
          <%= tag[:key] %> = "<%= tag[:value] %>"
          <%- end -%>
        }
        threshold                 = <%= resource.threshold %>
        <%- if resource.respond_to?(:treat_missing_data) -%>
        treat_missing_data        = "<%= resource.treat_missing_data %>"
        <%- end -%>
      }
      <%- end -%>
      TEMPLATE
    end
  end
end
