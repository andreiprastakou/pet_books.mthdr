require 'benchmark'

class Bench
  DECIMALS = 3

  def self.log(action, &block)
    result = nil
    time = Benchmark.realtime do
      result = block.call
    end
    Rails.logger.info("[#{Time.current.utc.to_fs(:number)}] #{action} in #{time.round(DECIMALS)}s")
    result
  end
end
