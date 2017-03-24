require "spec_helper"

RSpec.describe Keisan::Exceptions do
  it "has correct structure" do
    expect(described_class::BaseError.superclass).to eq ::StandardError

    expect(described_class::StandardError.superclass).to eq described_class::BaseError
    expect(described_class::InternalError.superclass).to eq described_class::BaseError

    expect(described_class::NotImplementedError.superclass).to eq described_class::InternalError

    %w(InvalidToken TokenizingError ParseError ASTError InvalidFunctionError UndefinedFunctionError UndefinedVariableError UnmodifiableError).map do |klass_s|
      described_class.const_get(klass_s)
    end.each do |klass|
      expect(klass.superclass).to eq described_class::StandardError
    end
  end
end
