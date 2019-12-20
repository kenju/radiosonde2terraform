#!/usr/bin/env ruby

require 'erb'

module Radiosonde2terraform
  class Resolver
    def initialize
    end

    # @return [String] the generated .tf file
    def to_tf_conf(conf)
      resource = parse_conf(conf)
      ERB.new(cloudwatch_alarm_template).result(binding)
    end

    private

    class Resource < Struct.new(
      :resource_name,
      :actions_enabled,
      :alarm_name,
      :comparison_operator,
      :dimensions,
      :evaluation_periods,
      :insufficient_data_actions,
      :metric_name,
      :namespace,
      :ok_actions,
      :period,
      :statistic,
      :tags,
      :threshold,
    )
    end

    def parse_conf(conf)
      # TODO: implement
    end

    def cloudwatch_alarm_template
      <<~TEMPLATE
      resource "aws_cloudwatch_metric_alarm" "<%= resource.resource_name %>" {
        actions_enabled           = "<%= resource.actions_enabled %>"
        alarm_actions             = <%= resource.alarm_actions %>
        alarm_name                = "<%= resource.alarm_name %>"
        comparison_operator       = "<%= resource.comparison_operator %>"
        dimensions                = <%= resource.dimensions %>
        evaluation_periods        = "<%= resource.evaluation_periods %>"
        insufficient_data_actions = <%= resource.insufficient_data_actions %>
        metric_name               = "<%= resource.metric_name %>"
        namespace                 = "<%= resouce.namespace %>"
        ok_actions                = <%= resource.ok_actions %>
        period                    = "<%= resource.period %>"
        statistic                 = "<%= resource.statistic %>"
        tags                      = %<= resource.tags %>
        threshold                 = <%= resource.threshold %>
      }
      TEMPLATE
    end
  end
end
