RSpec.describe Radiosonde2terraform::Resolver do
  let(:resolver) { described_class.new }

  describe "#to_tf_conf" do
    context 'with single configuration' do
      it "does something useful" do
        conf = <<~CONF
        alarm "ads-aggregate-campaign-hourly-progression-errors" do
          namespace "AWS/Lambda"
          metric_name "Errors"
          dimensions "FunctionName"=>"ads-aggregate-campaign-hourly-progression"
          period 60
          statistic :sum
          threshold ">=", 1.0
          evaluation_periods 1
          actions_enabled true
          alarm_actions ["arn:aws:sns:ap-northeast-1:789035092620:ad-notification"]
          ok_actions []
          insufficient_data_actions []
        end
        CONF

        actual = resolver.to_tf_conf(conf)

        expected = <<~CONF
        resource "aws_cloudwatch_metric_alarm" "ads-aggregate-campaign-hourly-progression-errors" {
          alarm_name                = "ads-aggregate-campaign-hourly-progression-errors"
          metric_name               = "Errors"
          period                    = "60"
          statistic                 = "Sum"
          threshold                 = "1.0"
          comparison_operator       = "GreaterThanOrEqualToThreshold"
          evaluation_periods        = "1"
          actions_enabled           = "true"
          alarm_actions             = ["arn:aws:sns:ap-northeast-1:789035092620:ad-notification"]
          insufficient_data_actions = []
          ok_actions                = []

          dimensions = {
            FunctionName = "ads-aggregate-campaign-hourly-progression"
          }

          tags = {
            Project     = "ads"
            Environment = "production"
          }
        }
        CONF

        expect(actual).to eq(expected)
      end
    end
  end
end
