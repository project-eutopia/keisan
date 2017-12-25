require "spec_helper"

RSpec.describe "Turing machine" do
  let(:calculator) { Keisan::Calculator.new }

  before do
    calculator.evaluate("tape_positive = [0]")
    calculator.evaluate("tape_negative = []")
    calculator.evaluate("tape_index(index) = if (index >= 0, index, index.abs() - 1)")
    calculator.evaluate("tape_ensure_space(index) = { if (index >= 0, { while (index >= tape_positive.size, tape_positive = tape_positive + [0]); tape_positive[index] }, { let index = index.abs() - 1; while (index >= tape_negative.size, tape_negative = tape_negative + [0]); tape_negative[index] }) }")
    calculator.evaluate("tape_value(index) = {tape_ensure_space(index); if (index >= 0, tape_positive[tape_index(index)], tape_negative[tape_index(index)])}")

    calculator.evaluate("
      run_machine(machine) = {
        state = 0;
        index = 0;

        running = true;

        while(running, {
          value = tape_value(index);
          commands = machine[state][value]
          let abs_index = tape_index(index)

          if (index >= 0,
            tape_positive[abs_index] = commands[0]
          ,
            tape_negative[abs_index] = commands[0]
          );

          index = index + commands[1];
          state = commands[2];

          if (state < 0, running = false);
        })
      }"
    )
  end

  it "3-state busy beaver" do
    calculator.evaluate("machine = [[[1, 1, 1], [1, -1, 2]], [[1, -1, 0], [1, 1, 1]], [[1, -1, 1], [1, 0, -1]]]")
    calculator.evaluate("run_machine(machine)")
    expect(calculator.evaluate("(tape_positive + tape_negative).inject(0, total, value, total + value)").value).to eq 6
  end
end
