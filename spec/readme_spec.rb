require "spec_helper"
require "digest"

# NOTE: This test uses `eval` on lines pulled from the README.md file, which is dangerous if the
# README ends up containing bad code
#
# To mitigate this problem, we have a hard-coded checksum here that must be updated by hand when
# making code changes.  This will force developers to be aware of this problem when updating the README
RSpec.describe "README.md" do
  describe "code examples" do
    File.open(File.expand_path("../../README.md", __FILE__)) do |file|
      content = file.read
      digest = Digest::SHA256.hexdigest(content)

      # cat README.md | sha256sum
      expected_digest = "6f410103fd872b5767d8b4ca836f9e7ed38803a5a059cb44b7cc8f9b84b9bf3c"
      if digest != expected_digest
        raise "Invalid README file detected with SHA256 digest of #{digest}. Use command `cat README.md | sha256sum` to get correct digest if your changes to the README are safe. Aborting README test."
      end

      content.scan(/^```ruby$\n(?<block>(?:^.*?$\n)*?)^```$/m).map {|match| match[0].split("\n").map(&:strip)}
    end.each.with_index do |code_block, i|
      it "runs code example #{i} correctly: #{code_block}" do
        b = binding

        outputs = code_block.map do |line|
          begin
            # Capture output of any `puts` statements
            $stdout = StringIO.new
            result = eval(line, b)
            $stdout = STDOUT
            result
          rescue Keisan::Exceptions::BaseError => e
            e
          end
        end

        expectations = code_block.map do |line|
          match = line.match(/\A\#\=\>(.+)\z/)
          if match
            match2 = match[1].match(/Keisan::Exceptions::(.+?): (.+)/)
            if match2
              Keisan::Exceptions.const_get(match2[1]).new(match2[2])
            else
              eval match[1], b
            end
          else
            nil
          end
        end

        expectations.each.with_index do |expectation, i|
          case expectation
          when Keisan::Exceptions::BaseError
            expect(outputs[i-1].class).to eq expectation.class
            expect(outputs[i-1].message).to eq expectation.message
          when NilClass, FalseClass
            # Nothing
          else
            expect(outputs[i-1]).to eq expectation
          end
        end
      end
    end
  end
end
