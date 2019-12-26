RSpec.describe Radiosonde2terraform::Resolver do
  let(:resolver) { described_class.new(options: options) }
  let(:options) {
    Radiosonde2terraform::Options.new(
      default_tags: [
        { key: "Environment", value: "production" },
      ],
    )
  }

  describe "#to_tf_conf" do
    context 'with single configuration' do
      it "does something useful" do
        filepath = File.join(__dir__, "fixtures/simple.alarm")
        actual = resolver.to_tf_conf(filepath)

        expected = <<~CONF
        resource "aws_cloudwatch_metric_alarm" "foo-bar-alarm" {
          actions_enabled           = "true"
          alarm_actions             = ["arn:aws:sns:ap-northeast-1:999999999999:foo-notification"]
          alarm_description         = ""
          alarm_name                = "foo-bar-alarm"
          comparison_operator       = "GreaterThanOrEqualToThreshold"
          dimensions                = {
            FunctionName = "foo-bar"
          }
          evaluation_periods        = "1"
          insufficient_data_actions = []
          metric_name               = "Errors"
          namespace                 = "AWS/Lambda"
          ok_actions                = []
          period                    = "60"
          statistic                 = "Sum"
          tags                      = {
            Environment = "production"
          }
          threshold                 = 1.0
        }
        CONF

        expect(actual).to eq(expected)
      end
    end

    context 'with "treat_missing_daga"' do
      it "does something useful" do
        filepath = File.join(__dir__, "fixtures/simple-with-treat-missing-data.alarm")
        actual = resolver.to_tf_conf(filepath)

        expected = <<~CONF
        resource "aws_cloudwatch_metric_alarm" "foo-bar-alarm" {
          actions_enabled           = "true"
          alarm_actions             = ["arn:aws:sns:ap-northeast-1:999999999999:foo-notification"]
          alarm_description         = "here is my description"
          alarm_name                = "foo-bar-alarm"
          comparison_operator       = "GreaterThanOrEqualToThreshold"
          dimensions                = {
            FunctionName = "foo-bar"
          }
          evaluation_periods        = "1"
          insufficient_data_actions = []
          metric_name               = "Errors"
          namespace                 = "AWS/Lambda"
          ok_actions                = []
          period                    = "60"
          statistic                 = "Sum"
          tags                      = {
            Environment = "production"
          }
          threshold                 = 1.0
          treat_missing_data        = "missing"
        }
        CONF

        expect(actual).to eq(expected)
      end
    end
  end
end
